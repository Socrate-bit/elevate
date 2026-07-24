import 'package:equatable/equatable.dart';

import '../../chat/services/chat_insight.dart';

/// A generated [ChatInsight] surfaced in the Journal, paired with the moment it
/// was created (for the date label + newest-first sorting) and its source
/// conversation. The [insight] itself is what the detail screen renders.
class JournalInsight extends Equatable {
  final ChatInsight insight;
  final DateTime createdAt;
  final String conversationId;

  const JournalInsight({
    required this.insight,
    required this.createdAt,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [insight, createdAt, conversationId];
}
