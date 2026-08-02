import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../adventure/cubit/adventure_cubit.dart';
import '../../home/models/default_task.dart';
import '../../memory/cubit/memory_cubit.dart';
import '../../memory/cubit/memory_state.dart';
import '../../memory/models/life_rating.dart';
import '../../mood/cubit/mood_cubit.dart';
import '../../mood/models/mood_entry.dart';
import '../../mood/services/mood_service.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_palette.dart';
import '../../subscription/services/analytics_service.dart';
import '../services/chat_firestore_service.dart';
import '../services/chat_form.dart';
import '../services/chat_insight.dart';
import '../services/chat_message.dart';
import '../services/chat_mission_suggestion.dart';
import '../services/chat_mood_check_in.dart';
import '../services/chat_routine_mutation.dart';
import '../services/gemini_service.dart';
import '../services/voice_service.dart';
import 'chat_state.dart';

/// Owns the active conversation: messages stream, send-text, voice input,
/// form answers, and routine mutations. Each user turn calls the Answerer
/// ([GeminiClient.answer]) and fires the background memory builder.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required String conversationId,
    RoutineCubit? routineCubit,
    MemoryCubit? memoryCubit,
    MoodCubit? moodCubit,
    AdventureCubit? adventureCubit,
    bool autoStart = false,
    ChatRepository? repository,
    GeminiClient? gemini,
    VoiceController? voice,
    Uuid? uuid,
  }) : _repo = repository ?? ChatFirestoreService.instance,
       _gemini = gemini ?? GeminiService.instance,
       _voice = voice ?? VoiceService.instance,
       _routineCubit = routineCubit,
       _memoryCubit = memoryCubit,
       _moodCubit = moodCubit,
       _adventureCubit = adventureCubit,
       _uuid = uuid ?? const Uuid(),
       super(
         ChatState(
           conversationId: conversationId,
           isLoading: true,
           isSending:
               autoStart, // show typing indicator from the very first frame
         ),
       ) {
    _subscribe();
    _mirrorMemoryProgress();
    if (autoStart) unawaited(_doStart());
  }

  final ChatRepository _repo;
  final GeminiClient _gemini;
  final VoiceController _voice;
  final RoutineCubit? _routineCubit;
  final MemoryCubit? _memoryCubit;
  final MoodCubit? _moodCubit;
  final AdventureCubit? _adventureCubit;
  final Uuid _uuid;
  StreamSubscription? _sub;
  StreamSubscription? _memorySub;

  /// Guards the "quick introspection" default task so it's marked done at most
  /// once per chat session (the completion itself is also idempotent per day).
  bool _introspectionMarked = false;

  /// An insight requires more than this many messages of substance since the
  /// last one before it can be revealed — a floor the model-driven progress
  /// can't override.
  static const _insightMinMessages = 5;

  /// If the user never taps, an insight is generated automatically after this
  /// many user turns since the last insight.
  static const _insightAutoThreshold = 20;

  /// XP awarded (as coins + strikes) the first time an insight is opened.
  static const kInsightRewardXp = 10;

  /// Guards against overlapping insight generations.
  bool _insightInFlight = false;

  /// Fill of the insight ring in [0,1] — the memory builder's latest estimate.
  double get insightProgress => state.insightProgress;

  /// Whether the user may reveal an insight now: the builder judged it ready and
  /// the conversation has enough substance since the last insight.
  bool get isInsightReady =>
      state.insightProgress >= 1.0 &&
      state.messagesSinceLastInsight.length > _insightMinMessages;

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo
        .watchMessages(state.conversationId)
        .listen(
          (messages) {
            emit(state.copyWith(messages: messages, isLoading: false));
          },
          onError: (e) {
            debugPrint('[ChatCubit] watchMessages error: $e');
            emit(state.copyWith(isLoading: false));
          },
        );
  }

  /// Mirrors the memory builder's insight progress/boundary into chat state so
  /// the ring reads it without recomputing.
  void _mirrorMemoryProgress() {
    final mem = _memoryCubit;
    if (mem == null) return;
    emit(
      state.copyWith(
        insightProgress: mem.state.insightProgress,
        insightBoundaryMs: mem.state.insightBoundaryMs,
      ),
    );
    _memorySub = mem.stream.listen((MemoryState ms) {
      if (isClosed) return;
      if (ms.insightProgress != state.insightProgress ||
          ms.insightBoundaryMs != state.insightBoundaryMs) {
        emit(
          state.copyWith(
            insightProgress: ms.insightProgress,
            insightBoundaryMs: ms.insightBoundaryMs,
          ),
        );
      }
    });
  }

  /// Sends [text] as a user message, then asks the Answerer for a reply.
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

    // Appending the user message also hides stale rapid answers (they are
    // derived from the latest message).
    emit(
      state.copyWith(messages: [...state.messages, userMsg], isSending: true),
    );

    try {
      await _repo.saveMessage(userMsg);
    } catch (e) {
      debugPrint('[ChatCubit] saveMessage user failed: $e');
      emit(
        state.copyWith(
          messages: state.messages.where((m) => m.id != userMsg.id).toList(),
          isSending: false,
        ),
      );
      rethrow;
    }

    final isFirstUserMessage =
        state.messages.where((m) => m.role == ChatRole.user).length == 1;
    if (isFirstUserMessage) {
      unawaited(_titleConversation(trimmed));
    }
    unawaited(_repo.updateConversation(state.conversationId, lastMessageAt: now));

    AnalyticsService.capture(AnalyticsService.chatMessageSent);

    // Sending a message completes the "quick introspection" default task.
    final adventure = _adventureCubit;
    if (!_introspectionMarked && adventure != null) {
      _introspectionMarked = true;
      unawaited(
        DefaultTaskCompletion.complete(
          task: kIntrospectionTask,
          adventure: adventure,
        ),
      );
    }

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

  /// Sends the AI's opening greeting without a user message.
  Future<void> startSession() async {
    if (state.messages.isNotEmpty || state.isSending) return;
    emit(state.copyWith(isSending: true));
    await _doStart();
  }

  /// Core session-start work — skips the guard so it can be called directly
  /// from the constructor when [autoStart] pre-sets [isSending] to true.
  Future<void> _doStart() async {
    try {
      final reply = await _callAnswer(const []);
      await _commitModelReply(reply);
    } catch (e) {
      debugPrint('[ChatCubit] startSession failed: $e');
    } finally {
      emit(state.copyWith(isSending: false));
    }
  }

  /// Hidden instruction behind the "Ask me an insightful question" starter.
  static const _openingQuestionPrompt =
      'Ask me one warm, open-ended, insightful question to help me start '
      'opening up. Reply with just the question.';

  /// Asks Appy for an insightful opening question without persisting a user
  /// message. The instruction is passed as a transient (unsaved) window turn.
  Future<void> promptOpeningQuestion() async {
    if (state.isSending) return;
    emit(state.copyWith(isSending: true));
    try {
      final transient = ChatMessage(
        id: _uuid.v4(),
        conversationId: state.conversationId,
        role: ChatRole.user,
        text: _openingQuestionPrompt,
        createdAt: DateTime.now(),
      );
      final window = [
        ...GeminiService.lastActiveDaysWindow(state.messages),
        transient,
      ];
      final reply = await _callAnswer(window);
      await _commitModelReply(reply);
    } catch (e) {
      debugPrint('[ChatCubit] promptOpeningQuestion failed: $e');
    } finally {
      emit(state.copyWith(isSending: false));
    }
  }

  Future<void> _generateModelReply() async {
    ChatMessage? modelMsg;
    try {
      final reply = await _callAnswer(
        GeminiService.lastActiveDaysWindow(state.messages),
      );
      modelMsg = await _commitModelReply(reply);
    } catch (e) {
      debugPrint('[ChatCubit] _generateModelReply failed: $e');
      rethrow;
    } finally {
      emit(state.copyWith(isSending: false));
    }
    // After the reply lands, run the background memory builder (which also
    // updates insight progress), then auto-generate an insight if the user has
    // gone long enough without tapping. Best-effort — never blocks the chat.
    if (modelMsg != null) {
      unawaited(
        (_memoryCubit?.analyze(state.conversationId) ?? Future.value())
            .then((_) => _maybeAutoGenerateInsight()),
      );
    }
  }

  /// Assembles the full memory context and calls the Answerer for [window].
  Future<AnswerResult> _callAnswer(List<ChatMessage> window) {
    final mem = _memoryCubit?.state;
    final today = _moodCubit?.state.weekMoods[DateTime.now().weekday % 7];
    final insights = <ChatInsight>[
      for (final m in state.messages)
        if (m.insight != null) m.insight!,
    ];
    final recentInsights = insights.length > 20
        ? insights.sublist(insights.length - 20)
        : insights;
    return _gemini.answer(
      windowMessages: window,
      recentSummaries: mem?.summaries ?? const [],
      recentInsights: recentInsights,
      facts: mem?.profile.facts ?? const {},
      events: mem?.events ?? const [],
      lifeRating: mem?.lifeRating ?? LifeRating.empty(),
      todayMood: today,
    );
  }

  /// Auto path: fire when the conversation has run long enough without an
  /// insight and the user hasn't manually revealed one.
  Future<void> _maybeAutoGenerateInsight() async {
    if (_insightInFlight) return;
    if (state.userTurnsSinceLastInsight < _insightAutoThreshold) return;
    await _generateInsight();
  }

  /// Manual path: called from the "insights forming" sheet once the ring is
  /// full. No-op until the builder judges an insight ready.
  Future<void> generateInsightNow() async {
    if (_insightInFlight) return;
    if (!isInsightReady) return;
    await _generateInsight();
  }

  /// Generates an insight from the conversation so far and, if one is produced,
  /// saves it as an inline model message and resets the progress boundary.
  Future<void> _generateInsight() async {
    _insightInFlight = true;
    emit(state.copyWith(isGeneratingInsight: true));
    try {
      final insight = await _gemini.generateInsight(
        history: state.messages.toList(),
      );
      if (insight == null) {
        debugPrint('[ChatCubit] insight generation returned nothing');
        return;
      }
      final now = DateTime.now();
      final msg = ChatMessage(
        id: _uuid.v4(),
        conversationId: state.conversationId,
        role: ChatRole.model,
        text: '',
        insight: insight,
        createdAt: now,
      );
      await _repo.saveMessage(msg);
      await _repo.updateConversation(state.conversationId, lastMessageAt: now);
      // Reset the progress boundary centrally so the ring restarts from empty.
      await _memoryCubit?.markInsight(now.millisecondsSinceEpoch);
      AnalyticsService.capture(AnalyticsService.chatInsightGenerated);
      debugPrint('[ChatCubit] saved insight "${insight.title}"');
    } catch (e) {
      debugPrint('[ChatCubit] _generateInsight failed: $e');
    } finally {
      _insightInFlight = false;
      emit(state.copyWith(isGeneratingInsight: false));
    }
  }

  /// Marks an insight message as opened and grants the one-time reward (coins +
  /// strikes). Returns true only on the first open.
  Future<bool> revealInsightReward(String messageId) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return false;
    final msg = state.messages[idx];
    if (msg.insight == null || msg.insightOpened) return false;

    final updated = List<ChatMessage>.from(state.messages)
      ..[idx] = msg.copyWith(insightOpened: true);
    emit(state.copyWith(messages: updated));

    try {
      await _repo.markInsightOpened(state.conversationId, messageId);
    } catch (e) {
      debugPrint('[ChatCubit] markInsightOpened failed: $e');
    }
    await _adventureCubit?.awardForCompletion(kInsightRewardXp);
    AnalyticsService.capture(AnalyticsService.chatInsightRewarded);
    debugPrint('[ChatCubit] insight opened reward granted ($messageId)');
    return true;
  }

  /// Persists an [AnswerResult] as a model [ChatMessage], applies any routine
  /// op, and stores the proposed rapid answers. Returns the saved message (or
  /// null when the reply was empty and dropped).
  Future<ChatMessage?> _commitModelReply(AnswerResult reply) async {
    ChatRoutineMutation? mutation;
    var replyText = reply.text;
    if (reply.routineOp != null) {
      mutation = await _applyRoutineOp(reply.routineOp!);
      replyText = replyText.isEmpty ? '' : replyText;
    }

    final card = reply.card;
    ChatForm? form;
    ChatMoodCheckIn? moodCheckIn;
    ChatMissionSuggestion? missionSuggestion;
    if (card != null) {
      switch (card.type) {
        case AnswerCardType.choices:
          if (card.options.isNotEmpty) {
            form = ChatForm(question: card.question, options: card.options);
          }
        case AnswerCardType.mood:
          moodCheckIn = ChatMoodCheckIn(question: card.question);
        case AnswerCardType.mission:
          if (card.missionKey.isNotEmpty) {
            missionSuggestion = ChatMissionSuggestion(
              toolKey: card.missionKey,
              reason: card.reason,
            );
          }
      }
    }

    // Never persist an empty bubble: no text and no interactive payload.
    final hasPayload = form != null ||
        missionSuggestion != null ||
        moodCheckIn != null ||
        mutation != null;
    if (replyText.isEmpty && !hasPayload) {
      debugPrint('[ChatCubit] dropping empty model reply (no text/payload)');
      return null;
    }

    // Rapid answers ride on the message so they survive leaving the chat.
    final modelMsg = ChatMessage(
      id: _uuid.v4(),
      conversationId: state.conversationId,
      role: ChatRole.model,
      text: replyText,
      form: form,
      missionSuggestion: missionSuggestion,
      moodCheckIn: moodCheckIn,
      routineMutation: mutation,
      proposedAnswers: reply.proposedAnswers,
      createdAt: DateTime.now(),
    );

    await _repo.saveMessage(modelMsg);
    await _repo.updateConversation(
      state.conversationId,
      lastMessageAt: modelMsg.createdAt,
    );
    debugPrint(
      '[ChatCubit] saved model reply (form=${form != null}, '
      'mission=${missionSuggestion != null}, mood=${moodCheckIn != null}, '
      'routine=${mutation != null}, proposed=${reply.proposedAnswers.length})',
    );
    return modelMsg;
  }

  /// Applies an Answerer-driven routine op and returns the receipt to attach to
  /// the chat message. [op] carries the op name plus routine fields.
  Future<ChatRoutineMutation?> _applyRoutineOp(Map<String, dynamic> op) async {
    final routineCubit = _routineCubit;
    if (routineCubit == null) return null;
    try {
      switch (op['op']) {
        case 'create':
          final draft = _routineFromArgs(op, existing: null);
          if (draft == null) return null;
          final saved = await routineCubit.addRoutine(draft);
          return ChatRoutineMutation(
            kind: ChatRoutineMutationKind.created,
            routineType: saved.type,
            routineId: saved.id,
            routineName: saved.name,
            emoji: saved.emoji,
            colorKey: saved.colorKey,
            scheduledDate: saved.scheduledDate,
          );
        case 'update':
          final id = op['routine_id']?.toString() ?? '';
          final existing = routineCubit.state.routines
              .where((r) => r.id == id)
              .toList();
          if (existing.isEmpty) return null;
          final draft = _routineFromArgs(op, existing: existing.first);
          if (draft == null) return null;
          await routineCubit.editRoutine(draft);
          return ChatRoutineMutation(
            kind: ChatRoutineMutationKind.updated,
            routineType: draft.type,
            routineId: draft.id,
            routineName: draft.name,
            emoji: draft.emoji,
            colorKey: draft.colorKey,
          );
        case 'delete':
          final id = op['routine_id']?.toString() ?? '';
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
            emoji: r.emoji,
            colorKey: r.colorKey,
          );
      }
    } catch (e) {
      debugPrint('[ChatCubit] applyRoutineOp failed: $e');
    }
    return null;
  }

  Routine? _routineFromArgs(
    Map<String, dynamic> args, {
    required Routine? existing,
  }) {
    final typeStr =
        args['type']?.toString() ??
        (existing?.type == RoutineType.habit ? 'habit' : 'action');
    final type = typeStr == 'habit' ? RoutineType.habit : RoutineType.action;
    final rawName = args['name']?.toString().trim();
    final name = (rawName == null || rawName.isEmpty)
        ? rawName
        : rawName.split(RegExp(r'\s+')).take(3).join(' ');
    if ((name == null || name.isEmpty) && existing == null) return null;

    final emoji = (args['emoji']?.toString() ?? '').isNotEmpty
        ? args['emoji'].toString()
        : (existing?.emoji ?? kDefaultRoutineEmoji);
    final colorKey = (args['color_key']?.toString() ?? '').isNotEmpty
        ? args['color_key'].toString()
        : (existing?.colorKey ?? kDefaultRoutineColorKey);

    int xp = existing?.xp ?? 10;
    final xpRaw = args['xp'];
    if (xpRaw is num) xp = xpRaw.toInt();

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
      emoji: emoji,
      colorKey: colorKey,
      xp: xp,
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
  /// user turn (sends the chosen label as a new user message).
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

  /// Marks a suggested activity as accepted (the card then opens its session).
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
        state.conversationId,
        messageId,
        true,
      );
      AnalyticsService.capture(AnalyticsService.chatMissionAccepted, {
        'tool_key': suggestion.toolKey,
      });
    } catch (e) {
      debugPrint('[ChatCubit] acceptMissionSuggestion failed: $e');
    }
  }

  /// Declines a suggested activity, then sends a short user turn so the
  /// conversation moves on.
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
        state.conversationId,
        messageId,
        false,
      );
      AnalyticsService.capture(AnalyticsService.chatMissionDeclined, {
        'tool_key': suggestion.toolKey,
      });
    } catch (e) {
      debugPrint('[ChatCubit] declineMissionSuggestion failed: $e');
    }

    await sendText('No thanks, not now.');
  }

  /// Records the user's mood selection from an inline check-in card.
  Future<void> selectMood(String messageId, MoodValue mood) async {
    final idx = state.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;
    final msg = state.messages[idx];
    final checkIn = msg.moodCheckIn;
    if (checkIn == null || checkIn.selectedMood != null) return;

    final updated = msg.copyWith(
      moodCheckIn: checkIn.copyWith(selectedMood: mood),
    );
    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..[idx] = updated;
    emit(state.copyWith(messages: updatedMessages));

    try {
      await _repo.updateMessageMoodCheckIn(
        state.conversationId,
        messageId,
        mood.name,
      );
      await MoodService.saveMood(mood);
      AnalyticsService.capture(AnalyticsService.moodRecorded, {
        'mood': mood.name,
        'source': 'chat',
      });
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
    _memorySub?.cancel();
    return super.close();
  }
}
