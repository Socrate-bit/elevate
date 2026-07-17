import 'package:equatable/equatable.dart';

import '../models/community_dm_message.dart';

/// State for a single 1:1 conversation's message list.
class CommunityDmState extends Equatable {
  final List<CommunityDmMessage> messages;
  final bool isLoading;

  const CommunityDmState({this.messages = const [], this.isLoading = true});

  CommunityDmState copyWith({
    List<CommunityDmMessage>? messages,
    bool? isLoading,
  }) => CommunityDmState(
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [messages, isLoading];
}
