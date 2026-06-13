import 'package:equatable/equatable.dart';

/// State of the tools page.
class ToolsPageState extends Equatable {
  final int navIndex;

  /// Tools is the 4th tab (index 3).
  const ToolsPageState({this.navIndex = 3});

  ToolsPageState copyWith({int? navIndex}) =>
      ToolsPageState(navIndex: navIndex ?? this.navIndex);

  @override
  List<Object?> get props => [navIndex];
}
