import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../memory/cubit/memory_cubit.dart';
import '../../mood/models/mood_entry.dart';
import '../../mood/services/mood_service.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_palette.dart';
import '../../subscription/services/analytics_service.dart';
import '../services/chat_firestore_service.dart';
import '../services/chat_message.dart';
import '../services/chat_routine_mutation.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import 'chat_state.dart';

/// Owns the active conversation: messages stream, send-text, voice input,
/// form answers, and routine mutations triggered by Gemini tool calls.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required String conversationId,
    RoutineCubit? routineCubit,
    MemoryCubit? memoryCubit,
    ChatRepository? repository,
    GeminiClient? gemini,
    VoiceController? voice,
    Uuid? uuid,
  })  : _repo = repository ?? ChatFirestoreService.instance,
        _gemini = gemini ?? GeminiService.instance,
        _voice = voice ?? VoiceService.instance,
        _routineCubit = routineCubit,
        _memoryCubit = memoryCubit,
        _uuid = uuid ?? const Uuid(),
        super(ChatState(conversationId: conversationId, isLoading: true)) {
    _subscribe();
  }

  final ChatRepository _repo;
  final GeminiClient _gemini;
  final VoiceController _voice;
  final RoutineCubit? _routineCubit;
  final MemoryCubit? _memoryCubit;
  final Uuid _uuid;
  StreamSubscription? _sub;
  bool _hasNewUserActivity = false;

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

    final isFirstUserMessage =
        state.messages.where((m) => m.role == ChatRole.user).length == 1;
    if (isFirstUserMessage) {
      unawaited(_titleConversation(trimmed));
    }
    // Bump lastMessageAt and unflag memoryExtracted so this conversation is
    // picked up for re-extraction on the next quit / app start.
    _hasNewUserActivity = true;
    unawaited(
      _repo.updateConversation(
        state.conversationId,
        lastMessageAt: now,
        memoryExtracted: false,
      ),
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

  Future<void> _generateModelReply() async {
    try {
      final memoryContext = _memoryCubit?.buildMemoryContext(
        excludeConversationId: state.conversationId,
      );
      final reply = await _gemini.send(
        history: state.messages.toList(),
        userText: state.messages.last.text,
        memoryContext: memoryContext,
      );

      ChatRoutineMutation? mutation;
      String replyText = reply.text ?? '';
      if (reply.routineToolCall != null) {
        mutation = await _applyRoutineToolCall(reply.routineToolCall!);
        replyText = '';
      }

      final modelMsg = ChatMessage(
        id: _uuid.v4(),
        conversationId: state.conversationId,
        role: ChatRole.model,
        text: replyText,
        form: reply.form,
        missionSuggestion: reply.missionSuggestion,
        moodCheckIn: reply.moodCheckIn,
        routineMutation: mutation,
        createdAt: DateTime.now(),
      );

      await _repo.saveMessage(modelMsg);
      await _repo.updateConversation(
        state.conversationId,
        lastMessageAt: modelMsg.createdAt,
      );
      debugPrint(
        '[ChatCubit] saved model reply '
        '(form=${reply.isForm}, mission=${reply.isMissionSuggestion}, '
        'mood=${reply.isMoodCheckIn}, routine=${mutation != null})',
      );
    } catch (e) {
      debugPrint('[ChatCubit] _generateModelReply failed: $e');
      rethrow;
    } finally {
      emit(state.copyWith(isSending: false));
    }
  }

  /// Applies a Gemini-driven routine mutation against [RoutineCubit] and
  /// returns the receipt to attach to the chat message.
  Future<ChatRoutineMutation?> _applyRoutineToolCall(
    RoutineToolCall call,
  ) async {
    final routineCubit = _routineCubit;
    if (routineCubit == null) return null;
    try {
      switch (call.tool) {
        case 'create_routine':
          final draft = _routineFromArgs(call.args, existing: null);
          if (draft == null) return null;
          final saved = await routineCubit.addRoutine(draft);
          return ChatRoutineMutation(
            kind: ChatRoutineMutationKind.created,
            routineType: saved.type,
            routineId: saved.id,
            routineName: saved.name,
            iconKey: saved.iconKey,
            colorKey: saved.colorKey,
          );
        case 'update_routine':
          final id = call.args['routine_id']?.toString() ?? '';
          final existing = routineCubit.state.routines
              .where((r) => r.id == id)
              .toList();
          if (existing.isEmpty) return null;
          final draft = _routineFromArgs(call.args, existing: existing.first);
          if (draft == null) return null;
          await routineCubit.editRoutine(draft);
          return ChatRoutineMutation(
            kind: ChatRoutineMutationKind.updated,
            routineType: draft.type,
            routineId: draft.id,
            routineName: draft.name,
            iconKey: draft.iconKey,
            colorKey: draft.colorKey,
          );
        case 'delete_routine':
          final id = call.args['routine_id']?.toString() ?? '';
          final match = routineCubit.state.routines
              .where((r) => r.id == id)
              .toList();
          if (match.isEmpty) return null;
          final r = match.first;
          await routineCubit.removeRoutine(id);
          return ChatRoutineMutation(
            kind: ChatRoutineMutationKind.deleted,
            routineType: r.type,
            routineId: r.id,
            routineName: r.name,
            iconKey: r.iconKey,
            colorKey: r.colorKey,
          );
      }
    } catch (e) {
      debugPrint('[ChatCubit] applyRoutineToolCall failed: $e');
    }
    return null;
  }

  Routine? _routineFromArgs(
    Map<String, dynamic> args, {
    required Routine? existing,
  }) {
    final typeStr = args['type']?.toString() ??
        (existing?.type == RoutineType.habit ? 'habit' : 'action');
    final type =
        typeStr == 'habit' ? RoutineType.habit : RoutineType.action;
    final name = args['name']?.toString().trim();
    if ((name == null || name.isEmpty) && existing == null) return null;

    final iconKey = (args['icon_key']?.toString() ?? '').isNotEmpty
        ? args['icon_key'].toString()
        : (existing?.iconKey ?? kDefaultRoutineIconKey);
    final colorKey = (args['color_key']?.toString() ?? '').isNotEmpty
        ? args['color_key'].toString()
        : (existing?.colorKey ?? kDefaultRoutineColorKey);

    final descRaw = args['description']?.toString();
    final description = (descRaw == null || descRaw.trim().isEmpty)
        ? existing?.description
        : descRaw.trim();

    final objectRaw = args['object_check']?.toString();
    final objectCheck = (objectRaw == null || objectRaw.trim().isEmpty)
        ? existing?.objectCheck
        : objectRaw.trim();

    DateTime? scheduledDate = existing?.scheduledDate;
    final dateRaw = args['scheduled_date']?.toString();
    if (dateRaw != null && dateRaw.isNotEmpty) {
      scheduledDate = DateTime.tryParse(dateRaw);
    }

    final daysRaw = args['scheduled_days'];
    final scheduledDays = (daysRaw is List && daysRaw.length == 7)
        ? daysRaw.map((e) => e == true).toList()
        : (existing?.scheduledDays ??
            const [false, false, false, false, false, false, false]);

    int? scheduledMinute = existing?.scheduledMinute;
    final minRaw = args['scheduled_minute'];
    if (minRaw is int) {
      scheduledMinute = minRaw >= 0 && minRaw < 24 * 60 ? minRaw : null;
    } else if (minRaw is num) {
      final v = minRaw.toInt();
      scheduledMinute = v >= 0 && v < 24 * 60 ? v : null;
    }

    final hasAlarm = args['has_alarm'] == true
        ? true
        : args['has_alarm'] == false
            ? false
            : (existing?.hasAlarm ?? false);

    return Routine(
      id: existing?.id ?? '',
      type: type,
      name: name ?? existing!.name,
      description: description,
      iconKey: iconKey,
      colorKey: colorKey,
      objectCheck: objectCheck,
      scheduledDate: type == RoutineType.action ? scheduledDate : null,
      scheduledDays: type == RoutineType.habit
          ? scheduledDays
          : const [false, false, false, false, false, false, false],
      scheduledMinute: scheduledMinute,
      hasAlarm: hasAlarm && scheduledMinute != null,
      createdAt: existing?.createdAt,
    );
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

    await sendText(form.options[optionIndex]);
  }

  Future<void> acceptMissionSuggestion(String messageId) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final msg = state.messages[idx];
    final suggestion = msg.missionSuggestion;
    if (suggestion == null || suggestion.accepted != null) return;

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..[idx] = msg.copyWith(
        missionSuggestion: suggestion.copyWith(accepted: true),
      );
    emit(state.copyWith(messages: updatedMessages));

    try {
      await _repo.updateMessageMissionSuggestion(
        state.conversationId, messageId, true,
      );
      AnalyticsService.capture(AnalyticsService.chatMissionAccepted, {
        'mission_type': suggestion.missionType,
      });
    } catch (e) {
      debugPrint('[ChatCubit] acceptMissionSuggestion failed: $e');
    }
  }

  Future<void> declineMissionSuggestion(String messageId) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final msg = state.messages[idx];
    final suggestion = msg.missionSuggestion;
    if (suggestion == null || suggestion.accepted != null) return;

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..[idx] = msg.copyWith(
        missionSuggestion: suggestion.copyWith(accepted: false),
      );
    emit(state.copyWith(messages: updatedMessages));

    try {
      await _repo.updateMessageMissionSuggestion(
        state.conversationId, messageId, false,
      );
      AnalyticsService.capture(AnalyticsService.chatMissionDeclined, {
        'mission_type': suggestion.missionType,
      });
    } catch (e) {
      debugPrint('[ChatCubit] declineMissionSuggestion failed: $e');
    }

    await sendText('No thanks, not now.');
  }

  /// Records the user's mood selection from an inline check-in card.
  /// Saves to Firestore, updates the message, then sends the mood as a user turn.
  Future<void> selectMood(String messageId, MoodValue mood) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final msg = state.messages[idx];
    final checkIn = msg.moodCheckIn;
    if (checkIn == null || checkIn.selectedMood != null) return;

    final updated = msg.copyWith(
      moodCheckIn: checkIn.copyWith(selectedMood: mood),
    );
    final updatedMessages = List<ChatMessage>.from(state.messages)..[idx] = updated;
    emit(state.copyWith(messages: updatedMessages));

    try {
      await _repo.updateMessageMoodCheckIn(
        state.conversationId,
        messageId,
        mood.name,
      );
      await MoodService.saveMood(mood);
      AnalyticsService.capture(
        AnalyticsService.moodRecorded,
        {'mood': mood.name, 'source': 'chat'},
      );
      debugPrint('[ChatCubit] mood selected in chat: ${mood.name}');
    } catch (e) {
      debugPrint('[ChatCubit] selectMood failed: $e');
    }

    await sendText("I'm feeling ${mood.name}.");
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

  Future<String> stopListening() async {
    await _voice.stop();
    final transcript = state.voicePartial;
    emit(state.copyWith(isListening: false, voicePartial: ''));
    return transcript;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    // Fire-and-forget memory extraction if the user sent at least one message
    // in this session. The extractor itself is best-effort and silent on
    // failure.
    if (_hasNewUserActivity) {
      final cubit = _memoryCubit;
      final cid = state.conversationId;
      if (cubit != null) {
        unawaited(cubit.extractNow(cid));
      }
    }
    return super.close();
  }
}
