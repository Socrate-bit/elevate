import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../subscription/services/analytics_service.dart';
import '../services/chat_firestore_service.dart';
import '../services/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import 'chat_state.dart';

/// Owns the active conversation: messages stream, send-text, voice input,
/// and form answers. Persists every turn through the injected services.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required String conversationId,
    ChatRepository? repository,
    GeminiClient? gemini,
    VoiceController? voice,
    Uuid? uuid,
  })  : _repo = repository ?? ChatFirestoreService.instance,
        _gemini = gemini ?? GeminiService.instance,
        _voice = voice ?? VoiceService.instance,
        _uuid = uuid ?? const Uuid(),
        super(ChatState(conversationId: conversationId, isLoading: true)) {
    _subscribe();
  }

  final ChatRepository _repo;
  final GeminiClient _gemini;
  final VoiceController _voice;
  final Uuid _uuid;
  StreamSubscription? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo.watchMessages(state.conversationId).listen(
      (messages) {
        emit(state.copyWith(messages: messages, isLoading: false));
      },
      onError: (e) {
        debugPrint('[ChatCubit] watchMessages error: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  /// Sends [text] as a user message, then asks Gemini for a reply.
  /// Optimistically inserts the user message before persisting.
  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      conversationId: state.conversationId,
      role: ChatRole.user,
      text: trimmed,
      createdAt: now,
    );

    // Optimistic insert so the user sees their bubble immediately.
    emit(state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
    ));

    try {
      await _repo.saveMessage(userMsg);
    } catch (e) {
      debugPrint('[ChatCubit] saveMessage user failed: $e');
      emit(state.copyWith(
        messages: state.messages.where((m) => m.id != userMsg.id).toList(),
        isSending: false,
      ));
      rethrow;
    }

    // First user message → name the conversation and update lastMessageAt.
    final isFirstUserMessage =
        state.messages.where((m) => m.role == ChatRole.user).length == 1;
    if (isFirstUserMessage) {
      unawaited(_titleConversation(trimmed));
    }
    unawaited(
      _repo.updateConversation(state.conversationId, lastMessageAt: now),
    );

    AnalyticsService.capture(AnalyticsService.chatMessageSent);

    await _generateModelReply();
  }

  Future<void> _titleConversation(String firstMessage) async {
    final title = await _gemini.generateTitle(firstMessage);
    try {
      await _repo.updateConversation(state.conversationId, title: title);
    } catch (e) {
      debugPrint('[ChatCubit] title update failed: $e');
    }
  }

  /// Asks Gemini for a reply given current local history, then persists.
  Future<void> _generateModelReply() async {
    try {
      final reply = await _gemini.send(
        history: state.messages.toList(),
        userText: state.messages.last.text,
      );

      final modelMsg = ChatMessage(
        id: _uuid.v4(),
        conversationId: state.conversationId,
        role: ChatRole.model,
        text: reply.text ?? '',
        form: reply.form,
        createdAt: DateTime.now(),
      );

      await _repo.saveMessage(modelMsg);
      await _repo.updateConversation(
        state.conversationId,
        lastMessageAt: modelMsg.createdAt,
      );
      debugPrint('[ChatCubit] saved model reply (form=${reply.isForm})');
    } catch (e) {
      debugPrint('[ChatCubit] _generateModelReply failed: $e');
      rethrow;
    } finally {
      emit(state.copyWith(isSending: false));
    }
  }

  /// Records the user's choice from a form message and treats it as the next
  /// user turn (sends the chosen label as a new user message to Gemini).
  Future<void> answerForm(String messageId, int optionIndex) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final msg = state.messages[idx];
    final form = msg.form;
    if (form == null) return;
    if (form.selectedIndex != null) return;
    if (optionIndex < 0 || optionIndex >= form.options.length) return;

    final updatedForm = form.copyWith(selectedIndex: optionIndex);
    final updatedMsg = msg.copyWith(form: updatedForm);

    // Optimistic local update.
    final updatedMessages = List<ChatMessage>.from(state.messages);
    updatedMessages[idx] = updatedMsg;
    emit(state.copyWith(messages: updatedMessages));

    try {
      await _repo.updateMessageForm(
        state.conversationId,
        messageId,
        optionIndex,
      );
      AnalyticsService.capture(AnalyticsService.chatFormAnswered, {
        'option_index': optionIndex,
      });
    } catch (e) {
      debugPrint('[ChatCubit] updateMessageForm failed: $e');
    }

    // Send the chosen option as the next user turn.
    await sendText(form.options[optionIndex]);
  }

  /// Starts voice capture; partial transcripts flow into [state.voicePartial].
  Future<void> startListening() async {
    if (state.isListening) return;
    final ok = await _voice.initialize();
    if (!ok) throw const VoiceUnavailableException();
    emit(state.copyWith(isListening: true, voicePartial: ''));
    try {
      await _voice.start(
        onPartial: (transcript) {
          emit(state.copyWith(voicePartial: transcript));
        },
      );
      AnalyticsService.capture(AnalyticsService.chatVoiceUsed);
    } catch (e) {
      debugPrint('[ChatCubit] startListening failed: $e');
      emit(state.copyWith(isListening: false));
      rethrow;
    }
  }

  /// Stops voice capture. Returns the final transcript so the UI can fill the
  /// composer (and optionally send it).
  Future<String> stopListening() async {
    await _voice.stop();
    final transcript = state.voicePartial;
    emit(state.copyWith(isListening: false, voicePartial: ''));
    return transcript;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
