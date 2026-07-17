import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../subscription/services/analytics_service.dart';
import '../models/community_conversation.dart';
import '../models/community_dm_message.dart';
import '../services/community_firestore_service.dart';
import '../services/community_repository.dart';
import 'community_dm_state.dart';

/// Owns the live message stream for one conversation and sends new messages.
class CommunityDmCubit extends Cubit<CommunityDmState> {
  CommunityDmCubit(
    this.conversation,
    this.currentUid, {
    CommunityRepository? repository,
    Uuid? uuid,
  }) : _repo = repository ?? CommunityFirestoreService.instance,
       _uuid = uuid ?? const Uuid(),
       super(const CommunityDmState()) {
    _subscribe();
    _markRead();
  }

  final CommunityConversation conversation;
  final String currentUid;
  final CommunityRepository _repo;
  final Uuid _uuid;
  StreamSubscription? _sub;

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo.watchMessages(conversation.id).listen(
      (messages) => emit(state.copyWith(messages: messages, isLoading: false)),
      onError: (e) {
        debugPrint('[CommunityDmCubit] watchMessages error: $e');
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  Future<void> _markRead() async {
    try {
      await _repo.markRead(conversation.id, currentUid);
    } catch (e) {
      debugPrint('[CommunityDmCubit] markRead failed: $e');
    }
  }

  /// Sends a message from the current user to the other participant.
  Future<void> send(String body) async {
    if (body.trim().isEmpty) return;
    final message = CommunityDmMessage(
      id: _uuid.v4(),
      senderUid: currentUid,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    try {
      await _repo.sendMessage(
        conversation,
        message,
        conversation.otherUid(currentUid),
      );
      AnalyticsService.capture(AnalyticsService.communityMessageSent);
    } catch (e) {
      debugPrint('[CommunityDmCubit] send failed: $e');
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
