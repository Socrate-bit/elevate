import 'package:equatable/equatable.dart';

/// State of the root navigation shell.
///
/// [selectedTab] drives the nav-bar highlight (0–4). [pageIndex] is the index
/// into the shell's `IndexedStack` (0 = Home, 1 = Community) and only changes
/// for the two tabs that map to a real page.
class MainShellState extends Equatable {
  final int selectedTab;
  final int pageIndex;

  const MainShellState({this.selectedTab = 0, this.pageIndex = 0});

  MainShellState copyWith({int? selectedTab, int? pageIndex}) => MainShellState(
    selectedTab: selectedTab ?? this.selectedTab,
    pageIndex: pageIndex ?? this.pageIndex,
  );

  @override
  List<Object?> get props => [selectedTab, pageIndex];
}
