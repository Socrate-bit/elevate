import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import 'chat_form.dart';
import 'chat_message.dart';
import 'chat_mission_suggestion.dart';
import 'chat_mood_check_in.dart';

/// Either a text reply, a structured multiple-choice form, a mission suggestion, or a mood check-in.
class GeminiReply {
  final String? text;
  final ChatForm? form;
  final ChatMissionSuggestion? missionSuggestion;
  final ChatMoodCheckIn? moodCheckIn;

  const GeminiReply._({
    this.text,
    this.form,
    this.missionSuggestion,
    this.moodCheckIn,
  });

  factory GeminiReply.text(String text) => GeminiReply._(text: text);
  factory GeminiReply.form(ChatForm form) => GeminiReply._(form: form);
  factory GeminiReply.missionSuggestion(ChatMissionSuggestion s) =>
      GeminiReply._(missionSuggestion: s);
  factory GeminiReply.moodCheckIn(ChatMoodCheckIn c) =>
      GeminiReply._(moodCheckIn: c);

  bool get isForm => form != null;
  bool get isMissionSuggestion => missionSuggestion != null;
  bool get isMoodCheckIn => moodCheckIn != null;
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
/// - `suggest_mission`: proposes a Levio mission card when context calls for it
class GeminiService implements GeminiClient {
  GeminiService();

  /// Default singleton used by production code.
  static final GeminiClient instance = GeminiService();

  static const _modelName = 'gemini-2.5-flash';
  static const _toolChoices = 'present_choices';
  static const _toolMission = 'suggest_mission';
  static const _toolMood = 'ask_mood';

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
            'Propose a Levio mission to the user when context suggests they want to exercise, '
            'focus, wake up, build a habit, or try something active.',
            parameters: {
              'mission_type': Schema.string(
                description: 'One of: pushUps, squats, shakePhone, math, affirmation, '
                    'skyPhoto, makeBed, objectHunt, petHunt, natureHunt, touchGrass, random.',
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
        ]),
      ],
    );
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
  /// Form and mission suggestion messages are serialized as model prose
  /// so Gemini retains context on what was offered and how the user responded.
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
        } else if (m.text.isNotEmpty) {
          out.add(Content.model([TextPart(m.text)]));
        }
      }
    }
    out.add(Content.text(userText));
    return out;
  }
}
