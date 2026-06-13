import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/chat_mock_data.dart';

/// Frosted "Start a conversation" card with a close button and three
/// emoji starter suggestions.
class ChatSuggestionsCard extends StatelessWidget {
  final ValueChanged<String> onPick;
  final VoidCallback onDismiss;

  const ChatSuggestionsCard({
    super.key,
    required this.onPick,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final suggestions = [
      ChatSuggestion(emoji: '☀️', label: l10n.chatPageSuggestTalkDay),
      ChatSuggestion(emoji: '❤️', label: l10n.chatPageSuggestComfort),
      ChatSuggestion(emoji: '🌿', label: l10n.chatPageSuggestReflect),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: ChatPalette.panel,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row: title + close.
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: ChatPalette.panelText,
                      size: 15.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      l10n.chatPageStartConversation,
                      style: TextStyle(
                        color: ChatPalette.panelText,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: withHaptic(onDismiss),
                      child: Icon(
                        Icons.close_rounded,
                        color: ChatPalette.panelText,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Three suggestion buttons.
                Row(
                  children: [
                    for (var i = 0; i < suggestions.length; i++) ...[
                      if (i > 0) SizedBox(width: 10.w),
                      Expanded(
                        child: _SuggestionButton(
                          suggestion: suggestions[i],
                          onTap: () => onPick(suggestions[i].label),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionButton extends StatelessWidget {
  final ChatSuggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionButton({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        height: 78.h,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: ChatPalette.suggestion,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(suggestion.emoji, style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 6.h),
            Text(
              suggestion.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: ChatPalette.suggestionText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
