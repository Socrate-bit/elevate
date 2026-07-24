import 'package:equatable/equatable.dart';

/// State of the shop overlay. Only tracks whether the shop modal is open so
/// the home top bar can reactively swap its settings icon for the coin balance.
class ShopState extends Equatable {
  /// Whether the shop modal is currently presented.
  final bool isOpen;

  const ShopState({this.isOpen = false});

  ShopState copyWith({bool? isOpen}) =>
      ShopState(isOpen: isOpen ?? this.isOpen);

  @override
  List<Object?> get props => [isOpen];
}
