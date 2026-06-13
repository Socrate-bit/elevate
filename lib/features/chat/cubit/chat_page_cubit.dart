import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/chat_mock_data.dart';
import 'chat_page_state.dart';

/// Drives the new illustrated chat page (mock data, local-only state).
class ChatPageCubit extends Cubit<ChatPageState> {
  ChatPageCubit() : super(const ChatPageState());

  /// Optimistically appends a user message and dismisses the suggestions card.
  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    debugPrint('[ChatPageCubit] sendMessage: $trimmed');
    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          ChatBubbleMessage(isUser: true, text: trimmed),
        ],
        showSuggestions: false,
      ),
    );
  }

  /// Sends a starter suggestion as a user message.
  void pickSuggestion(String label) => sendMessage(label);

  /// Hides the "Start a conversation" card.
  void dismissSuggestions() {
    if (!state.showSuggestions) return;
    emit(state.copyWith(showSuggestions: false));
  }
}
