import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/routine.dart';

/// Bottom-sheet chooser between creating an Action or a Habit.
/// Returns the picked [RoutineType] or null if dismissed.
Future<RoutineType?> showRoutinePickerSheet(BuildContext context) {
  final c = AppColors.of(context);
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<RoutineType>(
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
              l10n.routinePickerTitle,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.routinePickerSubtitle,
              style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    icon: Icons.bolt_rounded,
                    label: l10n.routineTypeAction,
                    description: l10n.routineTypeActionDesc,
                    onTap: () => Navigator.pop(ctx, RoutineType.action),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _PickerTile(
                    icon: Icons.repeat_rounded,
                    label: l10n.routineTypeHabit,
                    description: l10n.routineTypeHabitDesc,
                    onTap: () => Navigator.pop(ctx, RoutineType.habit),
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

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _PickerTile({
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
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
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
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
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
