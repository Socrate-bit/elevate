import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../tools/models/tools_mock_data.dart';
import '../services/chat_mission_suggestion.dart';

/// Renders a guided-activity suggestion card emitted by Gemini via
/// `suggest_mission`. Shows start/decline buttons while pending; locks to a
/// status row once answered.
class ChatMissionCard extends StatelessWidget {
  final ChatMissionSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ChatMissionCard({
    super.key,
    required this.suggestion,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tool = ToolsMockData.byKey(suggestion.toolKey);
    final isPending = suggestion.accepted == null;
    final isAccepted = suggestion.accepted == true;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.85.sw),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: ChatPalette.appyBubble,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity icon + name.
            Row(
              children: [
                if (tool != null)
                  Image.asset(tool.iconAsset, width: 36.w, height: 36.w)
                else
                  Icon(
                    Icons.self_improvement_rounded,
                    size: 30.sp,
                    color: ChatPalette.accent,
                  ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    tool?.title ?? l10n.chatMissionStart,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: ChatPalette.appyText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // AI rationale.
            Text(
              suggestion.reason,
              style: TextStyle(fontSize: 13.sp, color: ChatPalette.timestamp),
            ),
            SizedBox(height: 12.h),
            // Action area.
            if (isPending) ...[
              _FilledButton(
                label: l10n.chatMissionStart,
                color: ChatPalette.accent,
                textColor: Colors.white,
                onTap: withMediumHaptic(onAccept)!,
              ),
              SizedBox(height: 8.h),
              _OutlinedButton(
                label: l10n.chatMissionDecline,
                borderColor: ChatPalette.cardBorder,
                textColor: ChatPalette.timestamp,
                onTap: withHaptic(onDecline)!,
              ),
            ] else
              _StatusRow(
                icon: isAccepted
                    ? Icons.check_circle_outline
                    : Icons.close_rounded,
                label: isAccepted
                    ? l10n.chatMissionAccepted
                    : l10n.chatMissionDeclined,
                color: ChatPalette.timestamp,
              ),
          ],
        ),
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _FilledButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String label;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _OutlinedButton({
    required this.label,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: color),
        ),
      ],
    );
  }
}
