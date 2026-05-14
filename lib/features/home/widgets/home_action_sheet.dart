import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

enum HomeAction { startChat, action, habit, mood, mission }

/// Bottom-sheet with a full-width Start Chat tile at the top, then 2×2 grid:
/// Action, Habit, Mood, Mission.
Future<HomeAction?> showHomeActionSheet(BuildContext context) {
  final c = AppColors.of(context);
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<HomeAction>(
    context: context,
    backgroundColor: c.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeAddTitle,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            // Full-width Start Chat tile
            GestureDetector(
              onTap: withHaptic(() => Navigator.pop(ctx, HomeAction.startChat)),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: c.primary.withAlpha(90),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white.withAlpha(220),
                      size: 22.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        l10n.chatModelName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        l10n.chatStartChat,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Action | Habit
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.bolt_rounded,
                    label: l10n.routineTypeAction,
                    description: l10n.routineTypeActionDesc,
                    onTap: () => Navigator.pop(ctx, HomeAction.action),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.repeat_rounded,
                    label: l10n.routineTypeHabit,
                    description: l10n.routineTypeHabitDesc,
                    onTap: () => Navigator.pop(ctx, HomeAction.habit),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Mood | Mission
            Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.mood_rounded,
                    label: l10n.moodSectionTitle,
                    description: l10n.homeAddMoodDesc,
                    onTap: () => Navigator.pop(ctx, HomeAction.mood),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.explore_rounded,
                    label: l10n.missionPickerTitle,
                    description: l10n.homeAddMissionDesc,
                    onTap: () => Navigator.pop(ctx, HomeAction.mission),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: c.background,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: c.primary.withAlpha(28),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: c.primary, size: 20.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              description,
              style: TextStyle(fontSize: 12.sp, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
