import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import 'chat_form.dart';
import 'chat_insight.dart';
import 'chat_message.dart';
import 'chat_mission_suggestion.dart';
import 'chat_mood_check_in.dart';

/// Tool call returned by Gemini that mutates the user's routines. The chat
/// layer applies it and produces a `ChatRoutineMutation` confirmation card.
class RoutineToolCall {
  final String tool; // 'create_routine' | 'update_routine' | 'delete_routine'
  final Map<String, dynamic> args;
  const RoutineToolCall({required this.tool, required this.args});
}

/// Either a text reply, a structured multiple-choice form, an activity
/// suggestion, a mood check-in, or a routine tool call from the model.
class GeminiReply {
  final String? text;
  final ChatForm? form;
  final ChatMissionSuggestion? missionSuggestion;
  final ChatMoodCheckIn? moodCheckIn;
  final RoutineToolCall? routineToolCall;

  const GeminiReply._({
    this.text,
    this.form,
    this.missionSuggestion,
    this.moodCheckIn,
    this.routineToolCall,
  });

  factory GeminiReply.text(String text) => GeminiReply._(text: text);
  factory GeminiReply.form(ChatForm form) => GeminiReply._(form: form);
  factory GeminiReply.missionSuggestion(ChatMissionSuggestion s) =>
      GeminiReply._(missionSuggestion: s);
  factory GeminiReply.moodCheckIn(ChatMoodCheckIn c) =>
      GeminiReply._(moodCheckIn: c);
  factory GeminiReply.routineToolCall(RoutineToolCall t) =>
      GeminiReply._(routineToolCall: t);

  bool get isForm => form != null;
  bool get isMissionSuggestion => missionSuggestion != null;
  bool get isMoodCheckIn => moodCheckIn != null;
  bool get isRoutineToolCall => routineToolCall != null;
}

/// Plain DTO produced by [GeminiClient.extractMemory]. The memory feature
/// converts these into Firestore documents (profile + life events + summary).
class ExtractedLifeEvent {
  final String title;
  final String description;
  final DateTime? occurredAt;

  const ExtractedLifeEvent({
    required this.title,
    required this.description,
    this.occurredAt,
  });
}

class MemoryExtraction {
  /// Sparse map of profile-fact keys → new/updated values.
  final Map<String, String> factUpdates;
  final List<ExtractedLifeEvent> newEvents;
  final String summary;

  const MemoryExtraction({
    required this.factUpdates,
    required this.newEvents,
    required this.summary,
  });

  static const empty = MemoryExtraction(
    factUpdates: {},
    newEvents: [],
    summary: '',
  );
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
  Future<GeminiReply> send({
    required List<ChatMessage> history,
    required String userText,
    String? memoryContext,
  });

  Future<String> generateTitle(String firstUserMessage);

  /// Extracts structured memory from a finished conversation. Returns sparse
  /// updates only; callers merge into existing storage.
  Future<MemoryExtraction> extractMemory({
    required List<ChatMessage> history,
    required Map<String, String> existingFacts,
    required List<String> existingEventTitles,
  });

  /// Distills the conversation so far into a single useful insight (title, a key
  /// citation from the chat, and a short paragraph). Returns null when there
  /// isn't enough material to say something meaningful.
  Future<ChatInsight?> generateInsight({required List<ChatMessage> history});

  /// Assesses how ready the conversation is to yield a meaningful insight, as a
  /// value in [0,1]. 1.0 means an insight can now be generated (deep enough
  /// exploration/resolution over more than five messages). Returns null when the
  /// assessment fails so callers can keep the previous value.
  Future<double?> assessInsightProgress({required List<ChatMessage> history});

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

/// Firebase Gemini implementation with function tools:
/// - `present_choices`: renders interactive multiple-choice cards inline in chat
/// - `suggest_mission`: proposes a guided-activity card when context calls for it
/// - `create_routine` / `update_routine` / `delete_routine`: mutate the user's
///   action/habit tracker
class GeminiService implements GeminiClient {
  GeminiService();

  /// Default singleton used by production code.
  static final GeminiClient instance = GeminiService();

  static const _modelName = 'gemini-2.5-flash';
  static const _toolChoices = 'present_choices';
  static const _toolMission = 'suggest_mission';
  static const _toolMood = 'ask_mood';
  static const _toolCreateRoutine = 'create_routine';
  static const _toolUpdateRoutine = 'update_routine';
  static const _toolDeleteRoutine = 'delete_routine';

  static const _systemInstruction = '''
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

## Memory
When provided, use what you know about the user (profile, recent life events,
session summaries, active commitments) to feel like you remember them — reference
it naturally, never recite it or name the source. Don't raise sensitive past
content on your own initiative.

## Your tools
Prefer these interactive tools over plain text when they fit:
- `present_choices` — a multiple-choice question (2–6 options) whenever you'd ask
  the user to pick from a small set. Use it instead of listing options as text.
- `ask_mood` — check in on how the user is feeling when their emotional state is
  relevant.
- `suggest_mission` — offer one of the ready-made guided activities below when it
  fits what the user needs right now.
- `create_routine` / `update_routine` / `delete_routine` — manage the user's
  action/habit tracker. Always propose a routine in plain prose first (its short
  name, whether it's a one-shot `action` or a recurring `habit`, and when it
  happens) and only call the tool AFTER the user confirms. An action disappears
  once done; a habit recurs on chosen weekdays. Keep `name` at most 3 words; pick a
  fitting `emoji`, `color_key`, and `xp` (small ~10, bigger up to 50).

## Guided missions you can suggest
Pass the key to `suggest_mission`:
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

Use plain prose for everything else.
''';

  static const _extractorSystemInstruction =
      'You analyze a finished chat conversation and extract structured memory '
      'about the user. Return JSON matching the schema. '
      '`profile_facts` are durable semantic facts about the person (age, gender, job, '
      'city, marital_status, purpose, what_tried, what_works, etc.) — include only NEW '
      'or UPDATED facts not already present in the existing list. Keys are short '
      'snake_case strings; values are concise strings. '
      '`new_life_events` are notable events that happened in the user\'s life that they '
      'mentioned (a job change, a breakup, a loss, a trip, a milestone). Skip anything '
      'whose title closely matches an already-extracted event. Leave `occurred_at_iso` '
      'empty if unknown. '
      '`summary` is a 1–3 sentence neutral recap of what was discussed in this '
      'conversation.';

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

  static const _insightProgressSystemInstruction =
      'You track how close a coaching conversation is to yielding ONE genuinely '
      'useful insight to reflect back to the user. Weigh two things: depth '
      '(has the user explored something meaningfully, reached some clarity, a '
      'reframe, or a resolution?) and length (a real insight needs more than '
      'five messages of substance). Return JSON matching the schema with a single '
      '`progress` field, a number from 0.0 to 1.0:\n'
      '- 1.0 means an insight can be generated right now: the exchange has more '
      'than five messages AND the exploration or resolution is satisfying.\n'
      '- Values in between reflect partial progress as the conversation deepens.\n'
      '- Near 0.0 for a thin or just-started exchange.\n'
      'Never return 1.0 when there are five or fewer messages, or when nothing '
      'meaningful has been explored yet.';

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

  GenerativeModel _buildChatModel(String? memoryContext) {
    final instruction = (memoryContext == null || memoryContext.isEmpty)
        ? _systemInstruction
        : '$_systemInstruction\n\n'
              '--- What you already know about this user ---\n'
              '$memoryContext';
    return FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(instruction),
      tools: [
        Tool.functionDeclarations([
          FunctionDeclaration(
            _toolChoices,
            'Render a multiple-choice question for the user.',
            parameters: {
              'question': Schema.string(
                description: 'Short prompt shown above the options.',
              ),
              'options': Schema.array(
                items: Schema.string(),
                description: 'Two to six concise answer labels.',
              ),
            },
          ),
          FunctionDeclaration(
            _toolMission,
            "Open one of the app's ready-made guided activities for the user "
            '(breathing, meditation, a reflection, a workout, …).',
            parameters: {
              'tool_key': Schema.string(
                description:
                    'One of: breathing, wimHof, meditation, stretching, walking, '
                    'sport, running, otherSport, gratitude, selfLove, mindfulness.',
              ),
              'reason': Schema.string(
                description:
                    'One short sentence explaining why this activity fits right now.',
              ),
            },
          ),
          FunctionDeclaration(
            _toolMood,
            'Check in on how the user is feeling when their emotional state is relevant.',
            parameters: {
              'question': Schema.string(
                description:
                    'Short contextual question to display, e.g. "How are you feeling right now?"',
              ),
            },
          ),
          FunctionDeclaration(
            _toolCreateRoutine,
            'Create a new routine (action or habit) for the user.',
            parameters: _routineSchema(includeId: false),
          ),
          FunctionDeclaration(
            _toolUpdateRoutine,
            "Update an existing routine. Pass `routine_id` plus the fields to change.",
            parameters: _routineSchema(includeId: true),
          ),
          FunctionDeclaration(
            _toolDeleteRoutine,
            'Delete a routine by id.',
            parameters: {
              'routine_id': Schema.string(
                description: 'Id of the routine to delete.',
              ),
            },
          ),
        ]),
      ],
    );
  }

  GenerativeModel _buildExtractorModel() {
    return FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(_extractorSystemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'profile_facts': Schema.array(
              items: Schema.object(
                properties: {
                  'key': Schema.string(
                    description:
                        'snake_case fact key, e.g. "job", "city", "purpose".',
                  ),
                  'value': Schema.string(
                    description: 'Short value for the fact.',
                  ),
                },
              ),
              description:
                  'New or updated profile facts. Skip facts already present unchanged.',
            ),
            'new_life_events': Schema.array(
              items: Schema.object(
                properties: {
                  'title': Schema.string(description: 'Short event title.'),
                  'description': Schema.string(
                    description: 'One sentence describing what happened.',
                  ),
                  'occurred_at_iso': Schema.string(
                    description:
                        'ISO 8601 date (YYYY-MM-DD) if known, else empty string.',
                  ),
                },
              ),
              description:
                  'Notable events mentioned by the user. Skip duplicates of existing events.',
            ),
            'summary': Schema.string(
              description: '1–3 sentence neutral recap of what was discussed.',
            ),
          },
        ),
      ),
    );
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

  GenerativeModel _buildInsightProgressModel() {
    return FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(_insightProgressSystemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'progress': Schema.number(
              description:
                  'Readiness for an insight, 0.0 (thin) to 1.0 (ready now).',
            ),
          },
        ),
      ),
    );
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

  static Map<String, Schema> _routineSchema({required bool includeId}) {
    return {
      if (includeId)
        'routine_id': Schema.string(
          description: 'Id of the routine to update.',
        ),
      'type': Schema.string(
        description: '"action" (one-shot) or "habit" (recurring).',
      ),
      'name': Schema.string(
        description: 'Short human-readable title, at most 3 words.',
      ),
      'description': Schema.string(
        description: 'Optional longer description, may be empty.',
      ),
      'emoji': Schema.string(
        description:
            'A single emoji shown on the routine tile, e.g. 🧘 for meditation, '
            '💧 for hydration, 🏃 for a run.',
      ),
      'color_key': Schema.string(
        description:
            'One of: orange, blue, green, purple, red, pink, yellow, teal.',
      ),
      'xp': Schema.integer(
        description: 'Points awarded for completing it (5–50). Default 10.',
      ),
      'object_check': Schema.string(
        description:
            'Free-text object name for photo validation, or empty for none. '
            'Example: "toothbrush", "book", "water bottle".',
      ),
      'scheduled_date': Schema.string(
        description:
            'Action-only ISO 8601 date (YYYY-MM-DD), or empty for no date.',
      ),
      'scheduled_days': Schema.array(
        items: Schema.boolean(),
        description:
            'Habit-only: 7-element array, index 0 = Sunday … 6 = Saturday.',
      ),
      'scheduled_minute': Schema.integer(
        description: 'Minutes since midnight (0-1439). Use -1 for no time set.',
      ),
      'has_alarm': Schema.boolean(
        description: 'True to ring an alarm at the scheduled time.',
      ),
    };
  }

  @override
  Future<GeminiReply> send({
    required List<ChatMessage> history,
    required String userText,
    String? memoryContext,
  }) async {
    try {
      final contents = _buildContents(history, userText);
      // Bound the request so a stalled network call surfaces as an error
      // (graceful empty state / snackbar) instead of an endless typing state.
      final response = await _buildChatModel(memoryContext)
          .generateContent(contents)
          .timeout(const Duration(seconds: 45));

      final calls = response.functionCalls.toList();
      if (calls.isNotEmpty) {
        debugPrint(
          '[GeminiService] function calls: '
          '${calls.map((c) => "${c.name}(${c.args})").join(" | ")}',
        );
        final call = calls.first;
        if (call.name == _toolChoices) {
          final args = call.args;
          final question = args['question']?.toString() ?? '';
          final rawOptions = args['options'];
          final options = rawOptions is List
              ? rawOptions.map((e) => e.toString()).toList()
              : <String>[];
          if (options.isNotEmpty) {
            return GeminiReply.form(
              ChatForm(question: question, options: options),
            );
          }
        }
        if (call.name == _toolMission) {
          final args = call.args;
          // The model sometimes passes the key under `mission_type` or nests it;
          // accept the common aliases so a suggestion never collapses to blank.
          final toolKey = (args['tool_key'] ?? args['mission_type'] ?? args['tool'])
                  ?.toString() ??
              '';
          final reason = args['reason']?.toString() ?? '';
          if (toolKey.isNotEmpty) {
            return GeminiReply.missionSuggestion(
              ChatMissionSuggestion(toolKey: toolKey, reason: reason),
            );
          }
          debugPrint('[GeminiService] suggest_mission called without a key: $args');
        }
        if (call.name == _toolMood) {
          final args = call.args;
          final question =
              args['question']?.toString() ?? 'How are you feeling right now?';
          return GeminiReply.moodCheckIn(ChatMoodCheckIn(question: question));
        }
        if (call.name == _toolCreateRoutine ||
            call.name == _toolUpdateRoutine ||
            call.name == _toolDeleteRoutine) {
          return GeminiReply.routineToolCall(
            RoutineToolCall(tool: call.name, args: Map.from(call.args)),
          );
        }
      }

      final text = response.text?.trim() ?? '';
      if (text.isEmpty) {
        debugPrint(
          '[GeminiService] empty text reply '
          '(calls=${calls.map((c) => c.name).toList()})',
        );
      }
      return GeminiReply.text(text);
    } catch (e, st) {
      debugPrint('[GeminiService] send failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<String> generateTitle(String firstUserMessage) async {
    try {
      final prompt =
          'Write a 3 to 6 word title for a chat that starts with this user message. '
          'Reply with just the title — no quotes, no punctuation at the end.\n\n'
          'Message: $firstUserMessage';
      final response = await _buildChatModel(
        null,
      ).generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return _fallbackTitle(firstUserMessage);
      return text.replaceAll('"', '').replaceAll("'", '').trim();
    } catch (e) {
      debugPrint('[GeminiService] generateTitle failed: $e');
      return _fallbackTitle(firstUserMessage);
    }
  }

  @override
  Future<MemoryExtraction> extractMemory({
    required List<ChatMessage> history,
    required Map<String, String> existingFacts,
    required List<String> existingEventTitles,
  }) async {
    try {
      final transcript = _renderTranscript(history);
      final factsBlock = existingFacts.isEmpty
          ? '(none)'
          : existingFacts.entries
                .map((e) => '- ${e.key}: ${e.value}')
                .join('\n');
      final eventsBlock = existingEventTitles.isEmpty
          ? '(none)'
          : existingEventTitles.map((t) => '- $t').join('\n');

      final prompt =
          'Conversation transcript:\n$transcript\n\n'
          'Existing profile facts (do not repeat unchanged):\n$factsBlock\n\n'
          'Already-extracted life events (do not duplicate):\n$eventsBlock\n\n'
          'Return JSON per the schema.';

      final response = await _buildExtractorModel().generateContent([
        Content.text(prompt),
      ]);
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return MemoryExtraction.empty;
      return _parseExtraction(text);
    } catch (e, st) {
      debugPrint('[GeminiService] extractMemory failed: $e\n$st');
      return MemoryExtraction.empty;
    }
  }

  static MemoryExtraction _parseExtraction(String jsonText) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } catch (e) {
      debugPrint('[GeminiService] extractMemory invalid JSON: $e');
      return MemoryExtraction.empty;
    }
    if (decoded is! Map) return MemoryExtraction.empty;

    final facts = <String, String>{};
    final rawFacts = decoded['profile_facts'];
    if (rawFacts is List) {
      for (final f in rawFacts) {
        if (f is Map) {
          final key = f['key']?.toString().trim() ?? '';
          final value = f['value']?.toString().trim() ?? '';
          if (key.isNotEmpty && value.isNotEmpty) facts[key] = value;
        }
      }
    }

    final events = <ExtractedLifeEvent>[];
    final rawEvents = decoded['new_life_events'];
    if (rawEvents is List) {
      for (final e in rawEvents) {
        if (e is Map) {
          final title = e['title']?.toString().trim() ?? '';
          if (title.isEmpty) continue;
          final desc = e['description']?.toString().trim() ?? '';
          final iso = e['occurred_at_iso']?.toString().trim() ?? '';
          DateTime? occurred;
          if (iso.isNotEmpty) occurred = DateTime.tryParse(iso);
          events.add(
            ExtractedLifeEvent(
              title: title,
              description: desc,
              occurredAt: occurred,
            ),
          );
        }
      }
    }

    final summary = decoded['summary']?.toString().trim() ?? '';
    return MemoryExtraction(
      factUpdates: facts,
      newEvents: events,
      summary: summary,
    );
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
    // The model returns empty fields when there isn't enough to say.
    if (title.isEmpty || body.isEmpty) return null;
    return ChatInsight(title: title, quote: quote, body: body);
  }

  @override
  Future<double?> assessInsightProgress({
    required List<ChatMessage> history,
  }) async {
    try {
      final transcript = _renderTranscript(history);
      if (transcript.trim().isEmpty) return 0.0;
      final prompt =
          'Conversation transcript (since the last insight):\n$transcript\n\n'
          'Return JSON per the schema with the insight-readiness progress.';

      final response = await _buildInsightProgressModel()
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 20));
      final text = response.text?.trim() ?? '';
      if (text.isEmpty) return null;
      return _parseProgress(text);
    } catch (e, st) {
      debugPrint('[GeminiService] assessInsightProgress failed: $e\n$st');
      return null;
    }
  }

  static double? _parseProgress(String jsonText) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(jsonText);
    } catch (e) {
      debugPrint('[GeminiService] assessInsightProgress invalid JSON: $e');
      return null;
    }
    if (decoded is! Map) return null;
    final raw = decoded['progress'];
    final value = raw is num ? raw.toDouble() : double.tryParse('$raw');
    if (value == null) return null;
    return value.clamp(0.0, 1.0);
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
    // Keep the title to a single word, stripping any stray punctuation.
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

  /// Converts our local history into Firebase AI [Content] entries.
  /// Form, mood check-in, and routine-mutation messages are serialized
  /// as model prose so Gemini retains context.
  static List<Content> _buildContents(
    List<ChatMessage> history,
    String userText,
  ) {
    final out = <Content>[];
    for (final m in history) {
      if (m.role == ChatRole.user) {
        out.add(Content.text(m.text));
      } else {
        final form = m.form;
        final mutation = m.routineMutation;
        if (form != null) {
          final summary =
              'I offered these choices for "${form.question}": ${form.options.join(", ")}.';
          out.add(Content.model([TextPart(summary)]));
        } else if (m.moodCheckIn != null) {
          final checkIn = m.moodCheckIn!;
          final status = checkIn.selectedMood != null
              ? 'User selected: ${checkIn.selectedMood!.name}.'
              : 'Awaiting response.';
          out.add(
            Content.model([TextPart('I asked "${checkIn.question}". $status')]),
          );
        } else if (mutation != null) {
          out.add(
            Content.model([
              TextPart(
                'I ${mutation.kind.name} the ${mutation.routineType.name} '
                '"${mutation.routineName}" (id ${mutation.routineId}).',
              ),
            ]),
          );
        } else if (m.missionSuggestion != null) {
          final s = m.missionSuggestion!;
          final status = s.accepted == null
              ? 'Awaiting response.'
              : s.accepted!
                  ? 'User started it.'
                  : 'User declined.';
          out.add(Content.model([
            TextPart('I suggested the ${s.toolKey} activity. $status'),
          ]));
        } else if (m.text.isNotEmpty) {
          out.add(Content.model([TextPart(m.text)]));
        }
      }
    }
    out.add(Content.text(userText));
    return out;
  }
}
