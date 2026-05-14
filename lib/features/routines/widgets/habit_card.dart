import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/routine.dart';
import '../models/routine_palette.dart';

class HabitCard extends StatelessWidget {
  final Routine routine;
  final bool completedToday;

  /// True if [routine] is scheduled for today. Cards for non-today habits
  /// are dimmed and non-interactive (tap still opens edit).
  final bool scheduledToday;
  final VoidCallback onValidate;
  final VoidCallback onEdit;

  const HabitCard({
    super.key,
    required this.routine,
    required this.completedToday,
    required this.scheduledToday,
    required this.onValidate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tint = routineColor(routine.colorKey);
    final icon = routineIcon(routine.iconKey);
    final dimmed = !scheduledToday;

    return GestureDetector(
      onTap: (completedToday || !scheduledToday)
          ? withHaptic(onEdit)
          : withHaptic(onValidate),
      onLongPress: withHaptic(onEdit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16.r),
          border: completedToday
              ? Border.all(color: tint, width: 2)
              : null,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10),
          ],
        ),
        child: Opacity(
          opacity: dimmed ? 0.55 : 1.0,
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
                      _subtitle(l10n),
                      style:
                          TextStyle(fontSize: 13.sp, color: c.textSecondary),
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
                  color: completedToday ? tint : tint.withAlpha(60),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completedToday
                      ? Icons.check_rounded
                      : (routine.objectCheck != null
                          ? Icons.camera_alt_rounded
                          : Icons.check_rounded),
                  color: completedToday ? Colors.white : tint,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(AppLocalizations l10n) {
    final time = routine.scheduledMinute;
    final daysLabel = _daysLabel(l10n);
    if (time == null) return daysLabel;
    final h = time ~/ 60;
    final m = time % 60;
    final t = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    return '$daysLabel · $t';
  }

  String _daysLabel(AppLocalizations l10n) {
    final days = routine.scheduledDays;
    if (days.every((d) => d)) return l10n.alarmsEveryDay;
    if (days.every((d) => !d)) return l10n.routineHabitNoSchedule;
    if (days.length == 7 &&
        days[1] &&
        days[2] &&
        days[3] &&
        days[4] &&
        days[5] &&
        !days[0] &&
        !days[6]) {
      return l10n.alarmsWeekdays;
    }
    final selected = <String>[];
    for (var i = 0; i < days.length; i++) {
      if (days[i]) selected.add(localizedDayShort(l10n, i));
    }
    return selected.join(', ');
  }
}
