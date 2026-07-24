import 'package:equatable/equatable.dart';

import '../models/trophy.dart';

/// State for the trophies gallery: the earned trophies (newest first) plus the
/// initial-load flag.
class TrophiesState extends Equatable {
  final List<Trophy> trophies;
  final bool isLoading;

  const TrophiesState({this.trophies = const [], this.isLoading = true});

  TrophiesState copyWith({List<Trophy>? trophies, bool? isLoading}) =>
      TrophiesState(
        trophies: trophies ?? this.trophies,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object?> get props => [trophies, isLoading];
}
