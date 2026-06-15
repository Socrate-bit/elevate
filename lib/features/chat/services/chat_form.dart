import 'package:equatable/equatable.dart';

/// Multiple-choice form attached to a model message.
/// Produced when Gemini invokes the `present_choices` function tool.
class ChatForm extends Equatable {
  final String question;
  final List<String> options;

  /// Index of the option the user selected, or null when unanswered.
  final int? selectedIndex;

  const ChatForm({
    required this.question,
    required this.options,
    this.selectedIndex,
  });

  ChatForm copyWith({
    String? question,
    List<String>? options,
    int? selectedIndex,
  }) => ChatForm(
    question: question ?? this.question,
    options: options ?? this.options,
    selectedIndex: selectedIndex ?? this.selectedIndex,
  );

  Map<String, dynamic> toMap() => {
    'question': question,
    'options': options,
    if (selectedIndex != null) 'selectedIndex': selectedIndex,
  };

  static ChatForm fromMap(Map<String, dynamic> m) => ChatForm(
    question: m['question'] as String? ?? '',
    options: List<String>.from(m['options'] as List? ?? const []),
    selectedIndex: m['selectedIndex'] as int?,
  );

  @override
  List<Object?> get props => [question, options, selectedIndex];
}
