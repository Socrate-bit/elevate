import 'package:equatable/equatable.dart';

import '../models/journal_insight.dart';

/// State for the Journal: the full list of generated insights (newest first)
/// plus the initial-load flag.
class JournalState extends Equatable {
  final List<JournalInsight> insights;
  final bool isLoading;

  const JournalState({this.insights = const [], this.isLoading = true});

  JournalState copyWith({List<JournalInsight>? insights, bool? isLoading}) =>
      JournalState(
        insights: insights ?? this.insights,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [insights, isLoading];
}
