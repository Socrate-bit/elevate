import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Inline panel unfolding the AI-suggested rapid replies just above the
/// composer. Rendered in the page column (not a modal route) so opening it
/// never steals focus — the keyboard stays up. Tapping a reply hands the text
/// back via [onPick] (which sends it).
class ChatProposedAnswersPanel extends StatelessWidget {
  final List<String> answers;
  final ValueChanged<String> onPick;

  const ChatProposedAnswersPanel({
    super.key,
    required this.answers,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: ChatPalette.panelText,
                    size: 15.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    l10n.chatProposedAnswersTitle,
                    style: TextStyle(
                      color: ChatPalette.panelText,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              for (var i = 0; i < answers.length; i++) ...[
                if (i > 0) SizedBox(height: 8.h),
                _AnswerButton(label: answers[i], onTap: () => onPick(answers[i])),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AnswerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: ChatPalette.suggestion,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: ChatPalette.suggestionText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
