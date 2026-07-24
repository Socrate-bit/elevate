import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'shop_state.dart';

/// Drives the shop modal's open state so other widgets (e.g. the home top bar,
/// which swaps its settings icon for the coin balance) can react to it.
class ShopCubit extends Cubit<ShopState> {
  ShopCubit() : super(const ShopState());

  /// Marks the shop modal as open.
  void open() {
    debugPrint('[ShopCubit] shop opened');
    emit(state.copyWith(isOpen: true));
  }

  /// Marks the shop modal as dismissed.
  void dismiss() {
    debugPrint('[ShopCubit] shop closed');
    emit(state.copyWith(isOpen: false));
  }
}
