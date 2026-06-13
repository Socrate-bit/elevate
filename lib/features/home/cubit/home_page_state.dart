import 'package:equatable/equatable.dart';

import '../models/home_mock_data.dart';

/// State of the new illustrated home page.
class HomePageState extends Equatable {
  final int navIndex;
  final List<HomePlanItem> planItems;

  const HomePageState({
    this.navIndex = 0,
    this.planItems = HomeMockData.planItems,
  });

  HomePageState copyWith({int? navIndex, List<HomePlanItem>? planItems}) =>
      HomePageState(
        navIndex: navIndex ?? this.navIndex,
        planItems: planItems ?? this.planItems,
      );

  @override
  List<Object?> get props => [navIndex, planItems];
}
