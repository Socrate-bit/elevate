import 'package:equatable/equatable.dart';

/// State of the Journal page.
class JournalState extends Equatable {
  /// Selected bottom-nav tab (Journal = 2).
  final int navIndex;

  const JournalState({this.navIndex = 2});

  JournalState copyWith({int? navIndex}) =>
      JournalState(navIndex: navIndex ?? this.navIndex);

  @override
  List<Object?> get props => [navIndex];
}
