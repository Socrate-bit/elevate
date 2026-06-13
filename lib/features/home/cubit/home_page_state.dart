import 'package:equatable/equatable.dart';

import '../models/home_mock_data.dart';

/// State of the new illustrated home page.
class HomePageState extends Equatable {
  final List<HomePlanItem> planItems;

  const HomePageState({this.planItems = HomeMockData.planItems});

  HomePageState copyWith({List<HomePlanItem>? planItems}) =>
      HomePageState(planItems: planItems ?? this.planItems);

  @override
  List<Object?> get props => [planItems];
}
