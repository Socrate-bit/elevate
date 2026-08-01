import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../memory/models/life_event.dart';
import '../../memory/models/life_rating.dart';
import '../../memory/models/memory_summary.dart';
import '../../mood/models/mood_entry.dart';
import 'chat_insight.dart';
import 'chat_message.dart';

/// One interactive card the Answerer can attach to a reply.
enum AnswerCardType { choices, mood, mission }

/// The optional inline card carried by an [AnswerResult].
class AnswerCard {
  final AnswerCardType type;
  final String question; // choices / mood
  final List<String> options; // choices
  final String missionKey; // mission
  final String reason; // mission
  const AnswerCard({
    required this.type,
    this.question = '',
    this.options = const [],
    this.missionKey = '',
    this.reason = '',
  });
}

/// One structured turn from the Answerer: the assistant's reply, an optional
/// card, an optional routine mutation, and the tappable "rapid answers".
class AnswerResult {
  final String text;
  final AnswerCard? card;

  /// `{op: create|update|delete, ...routine fields}` — consumed by ChatCubit's
  /// routine apply path. Null when the turn touches no routine.
  final Map<String, dynamic>? routineOp;

  /// 0–4 short first-person replies the user could tap to respond.
  final List<String> proposedAnswers;

  const AnswerResult({
    required this.text,
    this.card,
    this.routineOp,
    this.proposedAnswers = const [],
  });

  factory AnswerResult.empty() => const AnswerResult(text: '');
}

/// A create/update/delete on a life event, produced by the memory builder.
class EventOp {
  final String op; // create | update | delete
  final String? id; // required for update/delete
  final String title;
  final String description;
  final DateTime? occurredAt;
  const EventOp({
    required this.op,
    this.id,
    this.title = '',
    this.description = '',
    this.occurredAt,
  });
}

/// A create/update on a rolling conversation summary.
class SummaryOp {
  final String op; // create | update
  final String? id; // required for update
  final String text;
  final String topic;
  const SummaryOp({
    required this.op,
    this.id,
    this.text = '',
    this.topic = '',
  });
}

/// The result of one background memory-builder pass.
class MemoryAnalysis {
  final Map<String, String> factUpserts;
  final List<String> factDeletes;
  final List<EventOp> eventOps;

  /// Sparse dimension→score(1-5) map, or null when the rating didn't change.
  final Map<String, int>? lifeRatingUpdate;
  final List<SummaryOp> summaryOps;

  /// Insight readiness [0,1], or null when the pass produced no assessment
  /// (so callers keep the previous value).
  final double? insightProgress;

  const MemoryAnalysis({
    required this.factUpserts,
    required this.factDeletes,
    required this.eventOps,
    required this.lifeRatingUpdate,
    required this.summaryOps,
    required this.insightProgress,
  });

  static const empty = MemoryAnalysis(
    factUpserts: {},
    factDeletes: [],
    eventOps: [],
    lifeRatingUpdate: null,
    summaryOps: [],
    insightProgress: null,
  );

  bool get isEmpty =>
      factUpserts.isEmpty &&
      factDeletes.isEmpty &&
      eventOps.isEmpty &&
      lifeRatingUpdate == null &&
      summaryOps.isEmpty;
}

/// Plain DTO produced by [GeminiClient.generateCitation]: a real citation from
/// a figure or book plus a badge [iconKey]/[colorKey] the model picked to match
/// its mood. The trophy layer maps this into a persisted trophy.
class GeneratedCitation {
  final String title;
  final String quote;
  final String author;
  final String source;
  final String iconKey;
  final String colorKey;

  const GeneratedCitation({
    required this.title,
    required this.quote,
    required this.author,
    required this.source,
    required this.iconKey,
    required this.colorKey,
  });
}

/// LLM surface the chat depends on. Implementations: [GeminiService] for
/// production (Firebase + Gemini), or a fake for tests.
abstract interface class GeminiClient {
  /// The hot-path chat call: produces the assistant reply + rapid answers from
  /// the recent conversation window and the full memory context.
  Future<AnswerResult> answer({
    required List<ChatMessage> windowMessages,
    required List<MemorySummary> recentSummaries,
    required List<ChatInsight> recentInsights,
    required Map<String, String> facts,
    required List<LifeEvent> events,
    required LifeRating lifeRating,
    MoodValue? todayMood,
  });

  /// The background builder call: reviews the recent window against current
  /// memory and returns fact/event/summary/life-rating ops + insight progress.
  Future<MemoryAnalysis> analyze({
    required List<ChatMessage> windowMessages,
    required Map<String, String> facts,
    required List<LifeEvent> events,
    required LifeRating lifeRating,
    required List<MemorySummary> recentSummaries,
  });

  Future<String> generateTitle(String firstUserMessage);

  /// Distills the conversation so far into a single useful insight (title, a key
  /// citation from the chat, and a short paragraph). Returns null when there
  /// isn't enough material to say something meaningful.
  Future<ChatInsight?> generateInsight({required List<ChatMessage> history});

  /// Produces a real, verbatim citation from a well-known figure or book,
  /// thematically tied to [context] (a general one if it's empty), that is not
  /// already in [avoid]. Also picks an [iconKey]/[colorKey] from the allowed
  /// sets. Returns null on failure so callers can fall back.
  Future<GeneratedCitation?> generateCitation({
    String? context,
    required List<String> avoid,
    required List<String> allowedIcons,
    required List<String> allowedColors,
  });
}

/// Firebase Gemini implementation. The chat turn ([answer]) and the memory
/// builder ([analyze]) both use structured-JSON `responseSchema` calls.
class GeminiService implements GeminiClient {
  GeminiService();

  /// Default singleton used by production code.
  static final GeminiClient instance = GeminiService();

  static const _modelName = 'gemini-2.5-flash';

  /// Messages from the last [days] *calendar days that had activity* (not the
  /// last N hours) — quiet days don't consume the window. Returned ascending.
  static List<ChatMessage> lastActiveDaysWindow(
    List<ChatMessage> messages, {
    int days = 3,
  }) {
    if (messages.isEmpty) return const [];
    int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
    final keys = <int>{for (final m in messages) dayKey(m.createdAt)};
    final keep = (keys.toList()..sort((a, b) => b.compareTo(a))).take(days).toSet();
    return messages.where((m) => keep.contains(dayKey(m.createdAt))).toList();
  }

  static const _answerPersona = '''
## Who you are
You are a personal growth coach inside a mobile chat app. Your one job is to help
the user grow in their life. You do that three ways, in whatever order the moment
calls for:
- Support — listen, validate, and help them feel heard.
- Explore — get curious, ask questions, help them understand what's really going on.
- Plan — turn insight into concrete, achievable action they can actually take.

## How you carry yourself
- Warm, calm, present. Talk like a real person, not a textbook.
- Brief. Short replies invite a response; long ones overwhelm.
- The user leads — you offer, they choose. Never push action or insight they
  aren't ready for.
- Honest over flattering. You can name patterns and gently challenge.
- You don't diagnose, give medical advice, or moralize.

## How you respond
Every turn you return ONE structured object:
- `reply_text`: your message to the user, in warm plain prose. Keep it brief.
- `card_type` + fields: optionally attach ONE interactive card (else "none"):
  - "choices" — a multiple-choice question. Set `card_question` and 2–6
    `card_options`. Use it instead of listing options as plain text.
  - "mood" — a mood check-in. Set `card_question` (e.g. "How are you feeling
    right now?"). Use when their emotional state is relevant.
  - "mission" — suggest one of the guided activities below. Set `mission_key`
    and a one-sentence `mission_reason`.
  `reply_text` may still introduce the card.
- `routine_op` (+ `routine_*`): manage the user's action/habit tracker. ALWAYS
  propose a routine in `reply_text` first (its short name, whether it's an
  "action" or a "habit", and when it happens) and only set `routine_op` to
  create/update/delete AFTER the user explicitly agrees; otherwise "none". An
  action is a one-shot that disappears once done; a habit recurs on chosen
  weekdays. `routine_name` ≤ 3 words; pick a fitting `routine_emoji`,
  `routine_color_key` (orange/blue/green/purple/red/pink/yellow/teal) and
  `routine_xp` (small ~10, up to 50). For update/delete set `routine_id`.
- `proposed_answers`: 3–4 SHORT first-person replies the user could tap to answer
  you (write them as if the user is speaking, e.g. "Yeah, that's it", "Not
  really", "Tell me more"). Leave empty only when a card already lists the
  options or no reply makes sense.

## Guided missions (mission_key values)
- `breathing` — a guided breathing exercise to calm down.
- `wimHof` — a Wim Hof power-breathing session.
- `meditation` — a guided meditation.
- `stretching` — a gentle stretching routine.
- `walking` — step outside for a mindful walk.
- `sport` — a guided workout to move with energy.
- `running` — go for a run.
- `otherSport` — any other physical activity.
- `gratitude` — a chat-based reflection naming things they're grateful for.
- `selfLove` — a chat-based self-compassion reflection.
- `mindfulness` — a chat-based reflection to come back to the present.

## Memory
Use what you know about the user (below) to feel like you remember them —
reference it naturally, never recite it or name the source. Don't raise
sensitive past content on your own initiative.''';

  static const _analyzerSystemInstruction = '''
You maintain a user's long-term memory from an ongoing coaching conversation.
Review the recent messages against the current memory and return JSON per the
schema. Only propose changes that are clearly warranted; return empty lists when
nothing changed.

- `fact_upserts`: durable semantic facts about the person (age, gender, job,
  city, marital_status, purpose, preferences, key past events…). snake_case
  keys, concise values. Include a key only to ADD or CORRECT it.
- `fact_deletes`: keys whose fact is no longer true and should be removed.
- `event_ops`: notable life events the user mentioned (a job change, a breakup,
  a loss, a trip, a milestone). op "create" for a new one; "update" (with the
  existing id) to refine wording/date; "delete" (with id) if retracted. Skip
  events already captured. Leave `occurred_at_iso` empty if unknown.
- `life_rating_updates`: only when the conversation reveals a real shift in how
  a life dimension is going. dimension is one of health, support, safety,
  environment, selfCare, enjoyment, job, meaning; value is 1 (low) to 5 (great).
  Empty when nothing changed.
- `summary_ops`: keep a rolling set of short conversation summaries. If the
  latest recent messages continue the SAME topic as the most recent existing
  summary, "update" that summary (pass its id) with the enriched recap; if the
  conversation has moved to a new topic/session, "create" a new one. `topic` is
  a short label. Do not create duplicates.
- `insight_progress`: 0.0–1.0 readiness for ONE genuinely useful insight to
  reflect back. Weigh depth (has something been meaningfully explored/resolved?)
  and length (a real insight needs more than five substantive messages). Never
  1.0 with five or fewer messages of substance.''';

  static const _insightSystemInstruction =
      'You read a chat between a user and their supportive coach, and surface ONE '
      'genuinely useful insight that reflects something back to the user — naming a '
      'pattern, reframing a worry, or unlocking a next step they could not quite see '
      'themselves. Speak warmly and directly to the user ("you"), like the coach. '
      'Return JSON matching the schema:\n'
      '- `title`: a short, punchy headline for the insight (a few words, no ending '
      'punctuation).\n'
      '- `quote`: one short verbatim sentence taken from the conversation that best '
      'captures the heart of the insight — copy it exactly, do not paraphrase.\n'
      '- `body`: 1–3 short paragraphs delivering the insight itself: specific to what '
      'was said, encouraging, and non-generic.\n'
      'If the conversation is too short or thin to say anything meaningful, return '
      'empty strings for all three fields.';

  static const _citationSystemInstruction =
      'You award a "wisdom trophy": ONE real, verbatim quotation from a well-known '
      'real figure (philosopher, writer, scientist, leader) or a real book. '
      'The quote must be genuine and correctly attributed — never invent a quote '
      'or misattribute one; if unsure of exact wording, choose a different quote '
      'you are certain about. '
      'Pick a citation that resonates with the themes in the provided context '
      '(the user\'s recent reflections). If the context is empty, pick a general '
      'uplifting or wise citation about growth, resilience, or self-compassion. '
      'Do NOT return any citation listed as already earned. '
      'Return JSON matching the schema:\n'
      '- `title`: a SINGLE evocative word naming the wisdom (e.g. "Resilience", '
      '"Courage", "Stillness"). Exactly one word, capitalized, no punctuation.\n'
      '- `quote`: the citation, verbatim, no surrounding quotation marks.\n'
      '- `author`: the person the quote is attributed to (or the book\'s author).\n'
      '- `source`: the book/work title if it comes from one, else an empty string.\n'
      '- `icon_key`: exactly one key from the allowed icon list that best fits the '
      'citation\'s mood.\n'
      '- `color_key`: exactly one key from the allowed color list that best fits '
      'the citation\'s mood.';

  // ---------------------------------------------------------------------------
  // Answerer
  // ---------------------------------------------------------------------------

  @override
  Future<AnswerResult> answer({
    required List<ChatMessage> windowMessages,
    required List<MemorySummary> recentSummaries,
    required List<ChatInsight> recentInsights,
    required Map<String, String> facts,
    required List<LifeEvent> events,
    required LifeRating lifeRating,
    MoodValue? todayMood,
  }) async {
    try {
      final memoryBlock = _renderMemoryBlock(
        facts: facts,
        events: events,
        summaries: recentSummaries,
        insights: recentInsights,
        lifeRating: lifeRating,
        todayMood: todayMood,
      );
      final response = await _buildAnswerModel(memoryBlock)
          .generateContent(_buildAnswerContents(windowMessages))
          .timeout(const Duration(seconds: 45));
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        debugPrint('[GeminiService] empty answer response');
        return AnswerResult.empty();
      }
      return _parseAnswer(text);
    } catch (e, st) {
      debugPrint('[GeminiService] answer failed: $e\n$st');
      rethrow;
    }
  }

  GenerativeModel _buildAnswerModel(String memoryBlock) {
    final instruction = memoryBlock.isEmpty
        ? _answerPersona
        : '$_answerPersona\n\n--- What you already know about this user ---\n$memoryBlock';
    return FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(instruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'reply_text': Schema.string(
              description: 'Your warm, brief message to the user.',
            ),
            'card_type': Schema.enumString(
              enumValues: ['none', 'choices', 'mood', 'mission'],
              description: 'Which inline card to attach, or "none".',
            ),
            'card_question': Schema.string(
              description: 'Question for a choices/mood card.',
            ),
            'card_options': Schema.array(
              items: Schema.string(),
              description: 'Two to six labels for a choices card.',
            ),
            'mission_key': Schema.string(
              description: 'Guided-activity key for a mission card.',
            ),
            'mission_reason': Schema.string(
              description: 'One sentence on why the mission fits now.',
            ),
            'routine_op': Schema.enumString(
              enumValues: ['none', 'create', 'update', 'delete'],
              description: 'Routine mutation to apply after user consent.',
            ),
            'routine_id': Schema.string(
              description: 'Id of the routine to update/delete.',
            ),
            'routine_type': Schema.string(
              description: '"action" (one-shot) or "habit" (recurring).',
            ),
            'routine_name': Schema.string(
              description: 'Short title, at most 3 words.',
            ),
            'routine_description': Schema.string(),
            'routine_emoji': Schema.string(
              description: 'A single emoji for the routine tile.',
            ),
            'routine_color_key': Schema.string(
              description:
                  'One of: orange, blue, green, purple, red, pink, yellow, teal.',
            ),
            'routine_xp': Schema.integer(
              description: 'Points for completing it (5–50).',
            ),
            'routine_object_check': Schema.string(
              description: 'Object name for photo validation, or empty.',
            ),
            'routine_scheduled_date': Schema.string(
              description: 'Action-only ISO date (YYYY-MM-DD), or empty.',
            ),
            'routine_scheduled_days': Schema.array(
              items: Schema.boolean(),
              description: 'Habit-only 7-element array, index 0 = Sunday.',
            ),
            'routine_scheduled_minute': Schema.integer(
              description: 'Minutes since midnight (0-1439), or -1 for none.',
            ),
            'routine_has_alarm': Schema.boolean(),
            'proposed_answers': Schema.array(
              items: Schema.string(),
              description:
                  '3–4 short first-person replies the user could tap; [] if none fit.',
            ),
          },
          optionalProperties: const [
            'card_question',
            'card_options',
            'mission_key',
            'mission_reason',
            'routine_id',
            'routine_type',
            'routine_name',
            'routine_description',
            'routine_emoji',
            'routine_color_key',
            'routine_xp',
            'routine_object_check',
            'routine_scheduled_date',
            'routine_scheduled_days',
            'routine_scheduled_minute',
            'routine_has_alarm',
          ],
        ),
      ),
    );
  }

  static List<Content> _buildAnswerContents(List<ChatMessage> windowMessages) {
    final out = <Content>[];
    for (final m in windowMessages) {
      if (m.role == ChatRole.user) {
        if (m.text.isNotEmpty) out.add(Content.text(m.text));
      } else {
        final prose = _modelTurnProse(m);
        if (prose.isNotEmpty) out.add(Content.model([TextPart(prose)]));
      }
    }
    // Opening turn: no history yet — nudge a warm greeting.
    if (out.isEmpty) {
      out.add(
        Content.text(
          '(The user just opened the chat. Greet them warmly and briefly, and '
          'invite them to share what is on their mind.)',
        ),
      );
    }
    return out;
  }

  /// Renders a stored model message back into prose so the model retains
  /// context for its cards/mutations.
  static String _modelTurnProse(ChatMessage m) {
    if (m.text.isNotEmpty) return m.text;
    final form = m.form;
    final mood = m.moodCheckIn;
    final mission = m.missionSuggestion;
    final mutation = m.routineMutation;
    if (form != null) {
      return 'I offered these choices for "${form.question}": '
          '${form.options.join(", ")}.';
    }
    if (mood != null) {
      final status = mood.selectedMood != null
          ? 'User selected: ${mood.selectedMood!.name}.'
          : 'Awaiting response.';
      return 'I asked "${mood.question}". $status';
    }
    if (mission != null) {
      final status = mission.accepted == null
          ? 'Awaiting response.'
          : mission.accepted!
          ? 'User started it.'
          : 'User declined.';
      return 'I suggested the ${mission.toolKey} activity. $status';
    }
    if (mutation != null) {
      return 'I ${mutation.kind.name} the ${mutation.routineType.name} '
          '"${mutation.routineName}".';
    }
    return '';
  }

  static AnswerResult _parseAnswer(String jsonText) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } catch (e) {
      debugPrint('[GeminiService] answer invalid JSON: $e');
      return AnswerResult.empty();
    }
    if (decoded is! Map) return AnswerResult.empty();

    final text = decoded['reply_text']?.toString().trim() ?? '';

    // Card.
    AnswerCard? card;
    final cardType = decoded['card_type']?.toString() ?? 'none';
    if (cardType == 'choices') {
      final options = _stringList(decoded['card_options']);
      if (options.isNotEmpty) {
        card = AnswerCard(
          type: AnswerCardType.choices,
          question: decoded['card_question']?.toString() ?? '',
          options: options,
        );
      }
    } else if (cardType == 'mood') {
      card = AnswerCard(
        type: AnswerCardType.mood,
        question: decoded['card_question']?.toString().trim().isNotEmpty == true
            ? decoded['card_question'].toString()
            : 'How are you feeling right now?',
      );
    } else if (cardType == 'mission') {
      final key = decoded['mission_key']?.toString().trim() ?? '';
      if (key.isNotEmpty) {
        card = AnswerCard(
          type: AnswerCardType.mission,
          missionKey: key,
          reason: decoded['mission_reason']?.toString() ?? '',
        );
      }
    }

    // Routine op.
    Map<String, dynamic>? routineOp;
    final op = decoded['routine_op']?.toString() ?? 'none';
    if (op == 'create' || op == 'update' || op == 'delete') {
      routineOp = {
        'op': op,
        'routine_id': decoded['routine_id']?.toString() ?? '',
        'type': decoded['routine_type']?.toString() ?? '',
        'name': decoded['routine_name']?.toString() ?? '',
        'description': decoded['routine_description']?.toString() ?? '',
        'emoji': decoded['routine_emoji']?.toString() ?? '',
        'color_key': decoded['routine_color_key']?.toString() ?? '',
        'xp': decoded['routine_xp'],
        'object_check': decoded['routine_object_check']?.toString() ?? '',
        'scheduled_date': decoded['routine_scheduled_date']?.toString() ?? '',
        'scheduled_days': decoded['routine_scheduled_days'],
        'scheduled_minute': decoded['routine_scheduled_minute'],
        'has_alarm': decoded['routine_has_alarm'],
      };
    }

    final proposed = _stringList(
      decoded['proposed_answers'],
    ).take(4).toList(growable: false);

    return AnswerResult(
      text: text,
      card: card,
      routineOp: routineOp,
      proposedAnswers: proposed,
    );
  }

  // ---------------------------------------------------------------------------
  // Memory / analysis builder
  // ---------------------------------------------------------------------------

  @override
  Future<MemoryAnalysis> analyze({
    required List<ChatMessage> windowMessages,
    required Map<String, String> facts,
    required List<LifeEvent> events,
    required LifeRating lifeRating,
    required List<MemorySummary> recentSummaries,
  }) async {
    try {
      if (!windowMessages.any((m) => m.role == ChatRole.user)) {
        return MemoryAnalysis.empty;
      }
      final transcript = _renderTranscript(windowMessages);
      final factsBlock = facts.isEmpty
          ? '(none)'
          : (facts.keys.toList()..sort())
                .map((k) => '- $k: ${facts[k]}')
                .join('\n');
      final eventsBlock = events.isEmpty
          ? '(none)'
          : events
                .map((e) => '- [${e.id}] ${e.title}: ${e.description}')
                .join('\n');
      final ratingBlock = lifeRating.ratings.isEmpty
          ? '(none)'
          : (lifeRating.ratings.keys.toList()..sort())
                .map((k) => '- $k: ${lifeRating.ratings[k]}/5')
                .join('\n');
      final summariesBlock = recentSummaries.isEmpty
          ? '(none)'
          : recentSummaries
                .map((s) => '- [${s.id}] (${s.topic}) ${s.text}')
                .join('\n');

      final prompt =
          'Recent conversation (last active days):\n$transcript\n\n'
          'Current facts:\n$factsBlock\n\n'
          'Current life events:\n$eventsBlock\n\n'
          'Current life rating:\n$ratingBlock\n\n'
          'Recent summaries (most recent first):\n$summariesBlock\n\n'
          'Return JSON per the schema.';

      final response = await _buildAnalyzerModel()
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 30));
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return MemoryAnalysis.empty;
      return _parseAnalysis(text);
    } catch (e, st) {
      debugPrint('[GeminiService] analyze failed: $e\n$st');
      return MemoryAnalysis.empty;
    }
  }

  GenerativeModel _buildAnalyzerModel() {
    return FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(_analyzerSystemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'fact_upserts': Schema.array(
              items: Schema.object(
                properties: {
                  'key': Schema.string(),
                  'value': Schema.string(),
                },
              ),
              description: 'Facts to add or correct.',
            ),
            'fact_deletes': Schema.array(
              items: Schema.string(),
              description: 'Fact keys to remove.',
            ),
            'event_ops': Schema.array(
              items: Schema.object(
                properties: {
                  'op': Schema.enumString(
                    enumValues: ['create', 'update', 'delete'],
                  ),
                  'id': Schema.string(
                    description: 'Existing event id for update/delete.',
                  ),
                  'title': Schema.string(),
                  'description': Schema.string(),
                  'occurred_at_iso': Schema.string(
                    description: 'YYYY-MM-DD if known, else empty.',
                  ),
                },
                optionalProperties: const [
                  'id',
                  'title',
                  'description',
                  'occurred_at_iso',
                ],
              ),
              description: 'Life-event mutations.',
            ),
            'life_rating_updates': Schema.array(
              items: Schema.object(
                properties: {
                  'dimension': Schema.string(),
                  'value': Schema.integer(),
                },
              ),
              description: 'Changed life dimensions (1–5). Empty if unchanged.',
            ),
            'summary_ops': Schema.array(
              items: Schema.object(
                properties: {
                  'op': Schema.enumString(enumValues: ['create', 'update']),
                  'id': Schema.string(
                    description: 'Existing summary id for update.',
                  ),
                  'text': Schema.string(),
                  'topic': Schema.string(),
                },
                optionalProperties: const ['id'],
              ),
              description: 'Rolling summary mutations.',
            ),
            'insight_progress': Schema.number(
              description: 'Insight readiness, 0.0 (thin) to 1.0 (ready now).',
            ),
          },
        ),
      ),
    );
  }

  static MemoryAnalysis _parseAnalysis(String jsonText) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } catch (e) {
      debugPrint('[GeminiService] analyze invalid JSON: $e');
      return MemoryAnalysis.empty;
    }
    if (decoded is! Map) return MemoryAnalysis.empty;

    final factUpserts = <String, String>{};
    final rawFacts = decoded['fact_upserts'];
    if (rawFacts is List) {
      for (final f in rawFacts) {
        if (f is Map) {
          final key = f['key']?.toString().trim() ?? '';
          final value = f['value']?.toString().trim() ?? '';
          if (key.isNotEmpty && value.isNotEmpty) factUpserts[key] = value;
        }
      }
    }

    final factDeletes = _stringList(decoded['fact_deletes']);

    final eventOps = <EventOp>[];
    final rawEvents = decoded['event_ops'];
    if (rawEvents is List) {
      for (final e in rawEvents) {
        if (e is! Map) continue;
        final op = e['op']?.toString().trim() ?? '';
        if (op != 'create' && op != 'update' && op != 'delete') continue;
        final id = e['id']?.toString().trim();
        if ((op == 'update' || op == 'delete') && (id == null || id.isEmpty)) {
          continue;
        }
        final iso = e['occurred_at_iso']?.toString().trim() ?? '';
        eventOps.add(
          EventOp(
            op: op,
            id: id,
            title: e['title']?.toString().trim() ?? '',
            description: e['description']?.toString().trim() ?? '',
            occurredAt: iso.isEmpty ? null : DateTime.tryParse(iso),
          ),
        );
      }
    }

    Map<String, int>? lifeRatingUpdate;
    final rawRating = decoded['life_rating_updates'];
    if (rawRating is List && rawRating.isNotEmpty) {
      final map = <String, int>{};
      for (final r in rawRating) {
        if (r is! Map) continue;
        final dim = r['dimension']?.toString().trim() ?? '';
        final v = r['value'];
        if (dim.isEmpty || !LifeRating.dimensions.contains(dim)) continue;
        final value = v is num ? v.toInt() : int.tryParse('$v');
        if (value == null) continue;
        map[dim] = value.clamp(1, 5);
      }
      if (map.isNotEmpty) lifeRatingUpdate = map;
    }

    final summaryOps = <SummaryOp>[];
    final rawSummaries = decoded['summary_ops'];
    if (rawSummaries is List) {
      for (final s in rawSummaries) {
        if (s is! Map) continue;
        final op = s['op']?.toString().trim() ?? '';
        if (op != 'create' && op != 'update') continue;
        final text = s['text']?.toString().trim() ?? '';
        if (text.isEmpty) continue;
        final id = s['id']?.toString().trim();
        if (op == 'update' && (id == null || id.isEmpty)) continue;
        summaryOps.add(
          SummaryOp(
            op: op,
            id: id,
            text: text,
            topic: s['topic']?.toString().trim() ?? '',
          ),
        );
      }
    }

    double? insightProgress;
    final rawProgress = decoded['insight_progress'];
    if (rawProgress is num) {
      insightProgress = rawProgress.toDouble().clamp(0.0, 1.0);
    } else if (rawProgress != null) {
      insightProgress = double.tryParse('$rawProgress')?.clamp(0.0, 1.0);
    }

    return MemoryAnalysis(
      factUpserts: factUpserts,
      factDeletes: factDeletes,
      eventOps: eventOps,
      lifeRatingUpdate: lifeRatingUpdate,
      summaryOps: summaryOps,
      insightProgress: insightProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // Title / insight / citation (unchanged surface)
  // ---------------------------------------------------------------------------

  @override
  Future<String> generateTitle(String firstUserMessage) async {
    try {
      final prompt =
          'Write a 3 to 6 word title for a chat that starts with this user message. '
          'Reply with just the title — no quotes, no punctuation at the end.\n\n'
          'Message: $firstUserMessage';
      final response = await FirebaseAI.googleAI()
          .generativeModel(model: _modelName)
          .generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return _fallbackTitle(firstUserMessage);
      return text.replaceAll('"', '').replaceAll("'", '').trim();
    } catch (e) {
      debugPrint('[GeminiService] generateTitle failed: $e');
      return _fallbackTitle(firstUserMessage);
    }
  }

  @override
  Future<ChatInsight?> generateInsight({
    required List<ChatMessage> history,
  }) async {
    try {
      final transcript = _renderTranscript(history);
      if (transcript.trim().isEmpty) return null;
      final prompt =
          'Conversation transcript:\n$transcript\n\n'
          'Return JSON per the schema with one useful insight.';

      final response = await _buildInsightModel()
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 45));
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return null;
      return _parseInsight(text);
    } catch (e, st) {
      debugPrint('[GeminiService] generateInsight failed: $e\n$st');
      return null;
    }
  }

  GenerativeModel _buildInsightModel() {
    return FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(_insightSystemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'title': Schema.string(
              description: 'Short headline for the insight. Empty if none.',
            ),
            'quote': Schema.string(
              description:
                  'One short verbatim sentence copied from the conversation.',
            ),
            'body': Schema.string(
              description: '1–3 short paragraphs delivering the insight.',
            ),
          },
        ),
      ),
    );
  }

  static ChatInsight? _parseInsight(String jsonText) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } catch (e) {
      debugPrint('[GeminiService] generateInsight invalid JSON: $e');
      return null;
    }
    if (decoded is! Map) return null;
    final title = decoded['title']?.toString().trim() ?? '';
    final quote = decoded['quote']?.toString().trim() ?? '';
    final body = decoded['body']?.toString().trim() ?? '';
    if (title.isEmpty || body.isEmpty) return null;
    return ChatInsight(title: title, quote: quote, body: body);
  }

  @override
  Future<GeneratedCitation?> generateCitation({
    String? context,
    required List<String> avoid,
    required List<String> allowedIcons,
    required List<String> allowedColors,
  }) async {
    try {
      final themes = (context == null || context.trim().isEmpty)
          ? '(no recent reflections — pick a general wise citation)'
          : context.trim();
      final earned = avoid.isEmpty
          ? '(none yet)'
          : avoid.map((e) => '- $e').join('\n');
      final prompt =
          "The user's recent reflections:\n$themes\n\n"
          'Already earned (do not repeat any of these):\n$earned\n\n'
          'Allowed icon keys: ${allowedIcons.join(", ")}\n'
          'Allowed color keys: ${allowedColors.join(", ")}\n\n'
          'Return JSON per the schema with one fitting citation.';

      final response = await _buildCitationModel()
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 45));
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return null;
      return _parseCitation(text);
    } catch (e, st) {
      debugPrint('[GeminiService] generateCitation failed: $e\n$st');
      return null;
    }
  }

  GenerativeModel _buildCitationModel() {
    return FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(_citationSystemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'title': Schema.string(
              description: 'Single evocative word naming the wisdom.',
            ),
            'quote': Schema.string(
              description: 'Verbatim citation, no surrounding quotation marks.',
            ),
            'author': Schema.string(
              description: 'Figure or book author the quote is attributed to.',
            ),
            'source': Schema.string(
              description: 'Book/work title, or empty string.',
            ),
            'icon_key': Schema.string(
              description: 'One key from the allowed icon list.',
            ),
            'color_key': Schema.string(
              description: 'One key from the allowed color list.',
            ),
          },
        ),
      ),
    );
  }

  static GeneratedCitation? _parseCitation(String jsonText) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } catch (e) {
      debugPrint('[GeminiService] generateCitation invalid JSON: $e');
      return null;
    }
    if (decoded is! Map) return null;
    final quote = decoded['quote']?.toString().trim() ?? '';
    final author = decoded['author']?.toString().trim() ?? '';
    if (quote.isEmpty || author.isEmpty) return null;
    final rawTitle = decoded['title']?.toString().trim() ?? '';
    final title = rawTitle.split(RegExp(r'\s+')).first.replaceAll(
      RegExp(r'[^A-Za-zÀ-ÿ-]'),
      '',
    );
    return GeneratedCitation(
      title: title,
      quote: quote,
      author: author,
      source: decoded['source']?.toString().trim() ?? '',
      iconKey: decoded['icon_key']?.toString().trim() ?? '',
      colorKey: decoded['color_key']?.toString().trim() ?? '',
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  /// Formats the full memory context appended to the Answerer's system prompt.
  static String _renderMemoryBlock({
    required Map<String, String> facts,
    required List<LifeEvent> events,
    required List<MemorySummary> summaries,
    required List<ChatInsight> insights,
    required LifeRating lifeRating,
    required MoodValue? todayMood,
  }) {
    final b = StringBuffer();

    if (facts.isNotEmpty) {
      b.writeln('Profile facts:');
      for (final k in facts.keys.toList()..sort()) {
        b.writeln('- $k: ${facts[k]}');
      }
    }

    if (lifeRating.ratings.isNotEmpty) {
      if (b.isNotEmpty) b.writeln();
      b.writeln('Life rating (1 low – 5 great):');
      for (final k in lifeRating.ratings.keys.toList()..sort()) {
        b.writeln('- $k: ${lifeRating.ratings[k]}/5');
      }
    }

    if (events.isNotEmpty) {
      if (b.isNotEmpty) b.writeln();
      b.writeln('Life events:');
      for (final e in events.take(20)) {
        b.writeln('- ${e.title}: ${e.description}');
      }
    }

    if (summaries.isNotEmpty) {
      if (b.isNotEmpty) b.writeln();
      b.writeln('Recent conversation summaries (most recent first):');
      for (final s in summaries.take(20)) {
        b.writeln('- ${s.text}');
      }
    }

    if (insights.isNotEmpty) {
      if (b.isNotEmpty) b.writeln();
      b.writeln('Insights already reflected back:');
      for (final i in insights.take(20)) {
        b.writeln('- ${i.title}: ${i.body}');
      }
    }

    if (todayMood != null) {
      if (b.isNotEmpty) b.writeln();
      b.writeln("Today's mood: ${todayMood.name} ${todayMood.emoji}");
    }

    return b.toString().trim();
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String _renderTranscript(List<ChatMessage> history) {
    final lines = <String>[];
    for (final m in history) {
      final role = m.role == ChatRole.user ? 'User' : 'Assistant';
      if (m.text.isNotEmpty) {
        lines.add('$role: ${m.text}');
        continue;
      }
      final form = m.form;
      final mission = m.missionSuggestion;
      final mood = m.moodCheckIn;
      final mutation = m.routineMutation;
      if (form != null) {
        lines.add(
          'Assistant: [asked "${form.question}", options: ${form.options.join(", ")}]',
        );
      } else if (mission != null) {
        lines.add(
          'Assistant: [suggested activity ${mission.toolKey}: ${mission.reason}]',
        );
      } else if (mood != null) {
        final chosen = mood.selectedMood?.name;
        lines.add(
          'Assistant: [mood check-in "${mood.question}"${chosen != null ? ', user picked $chosen' : ''}]',
        );
      } else if (mutation != null) {
        lines.add(
          'Assistant: [${mutation.kind.name} ${mutation.routineType.name} "${mutation.routineName}"]',
        );
      }
    }
    return lines.join('\n');
  }

  static String _fallbackTitle(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= 40) return trimmed;
    return '${trimmed.substring(0, 40)}…';
  }
}
