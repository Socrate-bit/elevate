import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../levio/missions/models/mission.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../services/chat_mission_suggestion.dart';

/// Renders a mission suggestion card emitted by Gemini via `suggest_mission`.
/// Shows accept/decline buttons while pending; locks to a status row once answered.
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
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final missionType = missionTypeFromString(suggestion.missionType);
    final info = missionInfoFor(missionType);
    final isPending = suggestion.accepted == null;
    final isAccepted = suggestion.accepted == true;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.85.sw),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mission icon + name
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: info.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(info.icon, color: info.iconColor, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    info.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // AI rationale
            Text(
              suggestion.reason,
              style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
            ),
            SizedBox(height: 12.h),
            // Action area
            if (isPending) ...[
              _FilledButton(
                label: l10n.chatMissionStart,
                color: c.primary,
                textColor: Colors.white,
                onTap: withMediumHaptic(onAccept)!,
              ),
              SizedBox(height: 8.h),
              _OutlinedButton(
                label: l10n.chatMissionDecline,
                borderColor: c.separator,
                textColor: c.textSecondary,
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
                color: c.textSecondary,
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
