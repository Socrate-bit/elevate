import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import 'chat_form.dart';
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

/// Either a text reply, a structured multiple-choice form, a mission suggestion,
/// a mood check-in, or a routine tool call from the model.
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
}

/// Firebase Gemini implementation with function tools:
/// - `present_choices`: renders interactive multiple-choice cards inline in chat
/// - `suggest_mission`: proposes a mission card when context calls for it
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
## Overview
You are an emotional and mental wellbeing coach.

Your role is to support the user through reflection, emotional regulation,
and small actionable steps toward better mental health. You combine the
warmth of a trusted listener with the skills of a coach trained in
evidence-based approaches: cognitive reframing, mindfulness, self-compassion,
motivational interviewing, and behavioral activation.

## Your stance
- Warm, calm, present. Speak like a real person, not a textbook.
- Curious before prescriptive. Understand before advising.
- Validate first, explore second, act third — in that order.
- Brief over verbose. Long replies overwhelm; short replies invite response.
- Honest. You can disagree, name patterns, and gently challenge — never flatter.
- The user leads. You offer; they choose. Never push an action or insight
  they aren't ready for.

## What you do well
- Hold space for difficult emotions without rushing to fix them
- Help the user name what they're feeling and why
- Notice patterns across sessions and reflect them back
- Offer concrete, small, achievable next steps when the user is ready
- Teach simple psychological concepts when they help (without lecturing)
- Help regulate acute emotion through grounding and breathing techniques
- Celebrate progress, however small

## What you don't do
- Diagnose ("you have depression / anxiety / ADHD")
- Give medical or pharmacological advice
- Pretend to be human if asked directly
- Offer false reassurance ("everything will be fine")
- Push the user toward action when they need to be heard
- Surface sensitive past content (trauma, past SI) unless the user brings
  it up or it's clearly relevant to what's happening now
- Moralize, judge, or lecture
- Use clinical jargon when plain language works

## How you use memory
You have access to:
- The user's profile (stable facts, goals, what works / doesn't work for them)
- Recent life events (last 20)
- Recent session summaries (last 20)
- Active commitments (things they're currently working on)

Use this context to feel like you remember the user — but reference it
naturally, the way a human coach would. Don't recite it. Don't say
"according to my records." If you reference something from the past,
frame it as "you mentioned a few weeks ago…" or simply act on the
knowledge without naming the source.

Never bring up sensitive past content (clinical concerns, trauma) on
your own initiative. It's in your context for continuity, not for
unprompted reference.

## Workflow
1. First message / Form: Hello X, how I can help you today? (OPTION FORM)
   - "💬 I want to talk about something"
   - "😶‍🌫️ Help me manage an emotion"
   - "🌧️/☀️ Why do I feel [X etc.] today?" (Based on daily mood entry / Don't show it if no entry)
   - "🔁 How is [open thread] going?" (If last session is existing / relevant)
   - "🤔 I don't know"
2. Deep breathing:
   - 2.1 🌳 "Let's ground first, or do you want to jump in?" (If user likes it / don't show if user doesn't like it) (OPTION FORM)
   - 2.2 🧘 "Did that help you feel calmer?" (If no data about whether they like it) (OPTION FORM)
3. Topic discussion:
   - You're free to do what you think is good for the user / respond to their need
   - Examples:
     - Emotional support / empathy — when user needs to feel heard
     - Exploration / going to the root — when there's a pattern worth examining
     - Advice / psychoeducation / wisdom — when user wants understanding or tools
     - Positive reframing — when stuck in a distorted narrative
   - You can use form / mood checking tool when necessary to help the user express themselves
4. Actions proposal form: "What feels right to do?"
   - "Do you want to sit with this, or would it help to think about what to do?"
   - Present 3 relevant actions as a form
   - Actions to regulate mood:
     - Gratitude practice (chat-based): 3 things you're grateful for right now
     - Positive reframing (chat-based)
     - Call someone you care about (action)
     - Do something you enjoy (action + photo check)
     - Walk outside (action + photo check)
     - Physical activity (action + photo check)
   - Actions in real life to work on the problem (propose only if not too many active commitments):
     - One-off action or new habit
     - Optional photo proof
     - Cap at 3 active commitments — if the user already has 3, check in on existing ones instead of proposing more
   - Always include a "something else" / "not right now" option
   - Follow-up if needed: "When will you do it?", "What might get in the way?"
5. Follow-up loop (next session or if chat continues after action):
   - "Last time you said you'd [action]. Did you do it?"
   - If yes: "How did it feel? Did it help?"
   - If no: "What got in the way?" (no judgment)

## Tools
You are inside a mobile chat app. Use these tools as directed:

Always use form when possible / set of option.
When you need the user to choose between a small finite set of options
(typically 2 to 6), call the `present_choices` tool with a short question
and clear option labels — do not list options as plain text.

When the user's message clearly indicates they want to exercise, build a habit,
focus, or try something physical or mindful, call the `suggest_mission` tool with
the most relevant mission type and a one-sentence reason. Only suggest reactively —
when the user's intent is explicit. Never suggest speculatively.

When the user's emotional state, stress level, energy, or wellbeing seems relevant
to the conversation, call the `ask_mood` tool to check in — reactively only, never speculatively.

When the user asks to add, change, or remove a habit or one-off action,
call the routine tools (`create_routine`, `update_routine`, `delete_routine`).
An "action" is a one-shot to-do that disappears once validated; a "habit" recurs on
specific weekdays. Pick reasonable defaults (icon_key, color_key) — see allowed values.

Use plain prose replies for everything else.
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
            'Propose a mission to the user when context suggests they want to exercise, '
            'focus, wake up, build a habit, or try something active.',
            parameters: {
              'mission_type': Schema.string(
                description: 'One of: pushUps, squats, shakePhone, math, affirmation, '
                    'breathing, skyPhoto, makeBed, objectHunt, petHunt, natureHunt, '
                    'touchGrass, random.',
              ),
              'reason': Schema.string(
                description: 'One short sentence explaining why this mission fits right now.',
              ),
            },
          ),
          FunctionDeclaration(
            _toolMood,
            'Check in on how the user is feeling when their emotional state is relevant.',
            parameters: {
              'question': Schema.string(
                description: 'Short contextual question to display, e.g. "How are you feeling right now?"',
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
                  'title': Schema.string(
                    description: 'Short event title.',
                  ),
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
              description:
                  '1–3 sentence neutral recap of what was discussed.',
            ),
          },
        ),
      ),
    );
  }

  static Map<String, Schema> _routineSchema({required bool includeId}) {
    return {
      if (includeId)
        'routine_id': Schema.string(description: 'Id of the routine to update.'),
      'type': Schema.string(
        description: '"action" (one-shot) or "habit" (recurring).',
      ),
      'name': Schema.string(description: 'Short human-readable name.'),
      'description': Schema.string(
        description: 'Optional longer description, may be empty.',
      ),
      'icon_key': Schema.string(
        description:
            'One of: star, running, walking, cycling, water, coffee, food, '
            'book, pencil, study, meditation, sleep, sun, leaf, gym, yoga, '
            'brush, music, paint, home, cleaning, shower, tooth, pill, heart, '
            'phone, work, plant, pet, check.',
      ),
      'color_key': Schema.string(
        description:
            'One of: orange, blue, green, purple, red, pink, yellow, teal.',
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
        description:
            'Minutes since midnight (0-1439). Use -1 for no time set.',
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
      final response =
          await _buildChatModel(memoryContext).generateContent(contents);

      final calls = response.functionCalls.toList();
      if (calls.isNotEmpty) {
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
          final rawType = args['mission_type']?.toString() ?? 'random';
          final reason = args['reason']?.toString() ?? '';
          return GeminiReply.missionSuggestion(
            ChatMissionSuggestion(missionType: rawType, reason: reason),
          );
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
      final response = await _buildChatModel(null).generateContent([
        Content.text(prompt),
      ]);
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

      final prompt = 'Conversation transcript:\n$transcript\n\n'
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
          events.add(ExtractedLifeEvent(
            title: title,
            description: desc,
            occurredAt: occurred,
          ));
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
          'Assistant: [suggested mission ${mission.missionType}: ${mission.reason}]',
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
  /// Form, mission suggestion, and routine-mutation messages are serialized
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
        final suggestion = m.missionSuggestion;
        final mutation = m.routineMutation;
        if (form != null) {
          final summary =
              'I offered these choices for "${form.question}": ${form.options.join(", ")}.';
          out.add(Content.model([TextPart(summary)]));
        } else if (suggestion != null) {
          final status = suggestion.accepted == true
              ? 'User accepted.'
              : suggestion.accepted == false
                  ? 'User declined.'
                  : 'Awaiting response.';
          out.add(Content.model([
            TextPart(
              'I suggested the "${suggestion.missionType}" mission: '
              '"${suggestion.reason}". $status',
            ),
          ]));
        } else if (m.moodCheckIn != null) {
          final checkIn = m.moodCheckIn!;
          final status = checkIn.selectedMood != null
              ? 'User selected: ${checkIn.selectedMood!.name}.'
              : 'Awaiting response.';
          out.add(Content.model([
            TextPart('I asked "${checkIn.question}". $status'),
          ]));
        } else if (mutation != null) {
          out.add(Content.model([
            TextPart(
              'I ${mutation.kind.name} the ${mutation.routineType.name} '
              '"${mutation.routineName}" (id ${mutation.routineId}).',
            ),
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
