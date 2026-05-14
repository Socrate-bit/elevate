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

/// LLM surface the chat depends on. Implementations: [GeminiService] for
/// production (Firebase + Gemini), or a fake for tests.
abstract interface class GeminiClient {
  Future<GeminiReply> send({
    required List<ChatMessage> history,
    required String userText,
  });

  Future<String> generateTitle(String firstUserMessage);
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

  static const _systemInstruction =
      'You are a helpful assistant inside a mobile chat app. '
      'When you need the user to choose between a small finite set of options '
      '(typically 2 to 6), call the `present_choices` tool with a short '
      "question and clear option labels — do not list options as plain text. "
      "When the user's message clearly indicates they want to exercise, build a habit, "
      'focus, or try something physical or mindful, call the `suggest_mission` tool with '
      'the most relevant mission type and a one-sentence reason. Only suggest reactively — '
      "when the user's intent is explicit. Never suggest speculatively. "
      "When the user's emotional state, stress level, energy, or wellbeing seems relevant "
      'to the conversation, call the `ask_mood` tool to check in — reactively only, never speculatively. '
      'When the user asks to add, change, or remove a habit or one-off action, '
      'call the routine tools (`create_routine`, `update_routine`, `delete_routine`). '
      'An "action" is a one-shot to-do that disappears once validated; a "habit" recurs on '
      'specific weekdays. Pick reasonable defaults (icon_key, color_key) — see allowed values. '
      'Use plain prose replies for everything else.';

  GenerativeModel? _model;

  GenerativeModel _getModel() {
    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      systemInstruction: Content.system(_systemInstruction),
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
  }) async {
    try {
      final contents = _buildContents(history, userText);
      final response = await _getModel().generateContent(contents);

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
      final response = await _getModel().generateContent([
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
