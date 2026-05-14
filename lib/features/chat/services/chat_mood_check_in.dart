import 'package:equatable/equatable.dart';

import '../../mood/models/mood_entry.dart';

/// Model for an inline mood check-in card rendered inside the AI chat.
class ChatMoodCheckIn extends Equatable {
  final String question;
  final MoodValue? selectedMood; // null until the user taps a mood

  const ChatMoodCheckIn({required this.question, this.selectedMood});

  ChatMoodCheckIn copyWith({String? question, MoodValue? selectedMood}) =>
      ChatMoodCheckIn(
        question: question ?? this.question,
        selectedMood: selectedMood ?? this.selectedMood,
      );

  Map<String, dynamic> toMap() => {
        'question': question,
        'selectedMood': selectedMood?.name,
      };

  factory ChatMoodCheckIn.fromMap(Map<String, dynamic> m) => ChatMoodCheckIn(
        question: m['question'] as String? ?? '',
        selectedMood: MoodValueX.fromName(m['selectedMood'] as String?),
      );

  @override
  List<Object?> get props => [question, selectedMood];
}
