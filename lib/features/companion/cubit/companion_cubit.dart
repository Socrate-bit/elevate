import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/auth_service.dart';

/// Streams the companion name the user chose during onboarding (stored on the
/// `users/{uid}/meta/onboarding` doc as `petName`) so the chat header and home
/// screen can address the pet by name. Falls back to [defaultName].
class CompanionCubit extends Cubit<String> {
  CompanionCubit() : super(defaultName);

  /// Fallback name when the user hasn't named their companion yet.
  static const defaultName = 'Appy';

  StreamSubscription? _sub;

  /// Subscribes to the onboarding doc. Call when auth flips to signed-in.
  void start() {
    final uid = AuthService.uidOrNull;
    if (uid == null) return;
    _sub?.cancel();
    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('onboarding')
        .snapshots()
        .listen(
      (doc) {
        final name = (doc.data()?['petName'] as String?)?.trim();
        emit(name == null || name.isEmpty ? defaultName : name);
      },
      onError: (e) {
        debugPrint('[CompanionCubit] watch petName error: $e');
      },
    );
  }

  /// Cancels the subscription and resets to the default. Call on sign-out.
  void clear() {
    _sub?.cancel();
    _sub = null;
    emit(defaultName);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
