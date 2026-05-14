import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/routine.dart';
import '../models/routine_palette.dart';

class ActionCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onValidate;
  final VoidCallback onEdit;

  const ActionCard({
    super.key,
    required this.routine,
    required this.onValidate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tint = routineColor(routine.colorKey);
    final icon = routineIcon(routine.iconKey);

    final time = routine.scheduledMinute;
    final date = routine.scheduledDate;
    final scheduleText = _scheduleText(time, date);

    return GestureDetector(
      onTap: withHaptic(onValidate),
      onLongPress: withHaptic(onEdit),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: tint.withAlpha(40),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: tint, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    scheduleText ??
                        (routine.objectCheck != null
                            ? l10n.routineCardObjectCheck(routine.objectCheck!)
                            : l10n.routineCardTapToValidate),
                    style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: tint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                routine.objectCheck != null
                    ? Icons.camera_alt_rounded
                    : Icons.check_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _scheduleText(int? minute, DateTime? date) {
    if (minute == null && date == null) return null;
    final parts = <String>[];
    if (date != null) {
      final now = DateTime.now();
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      parts.add(isToday
          ? 'Today'
          : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}');
    }
    if (minute != null) {
      final h = minute ~/ 60;
      final m = minute % 60;
      parts.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
    }
    return parts.join(' · ');
  }
}
