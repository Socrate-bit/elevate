import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/routine.dart';
import '../models/routine_palette.dart';

/// Read-only detail view for a single [Routine], opened when a task is tapped
/// from the plan. Shows, top to bottom: the emoji, the title, the recurrence
/// detail, the description, and the reward. Theme-adaptive.
class RoutineDetailScreen extends StatelessWidget {
  final Routine routine;

  const RoutineDetailScreen({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tint = routineColor(routine.colorKey);
    final description = routine.description?.trim();

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          // Color band tinted to the routine, with a back button.
          SliverToBoxAdapter(child: _HeaderBand(color: tint)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Emoji lifted onto the header band.
                  Center(
                    child: Transform.translate(
                      offset: Offset(0, -56.h),
                      child: _EmojiBadge(emoji: routine.emoji, tint: tint),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -32.h),
                    child: Column(
                      children: [
                        // Title.
                        Text(
                          routine.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Recurrence detail.
                        Text(
                          _recurrenceLabel(l10n),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: tint,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // Description.
                        _DetailCard(
                          label: l10n.routineDetailDescription,
                          child: Text(
                            (description == null || description.isEmpty)
                                ? l10n.routineDetailNoDescription
                                : description,
                            style: TextStyle(
                              fontSize: 15.sp,
                              height: 1.4,
                              color: (description == null || description.isEmpty)
                                  ? c.textSecondary
                                  : c.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Reward.
                        _DetailCard(
                          label: l10n.routineDetailReward,
                          child: Row(
                            children: [
                              Text(
                                l10n.routineDetailPoints(routine.xp),
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w800,
                                  color: c.textPrimary,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Image.asset(
                                'assets/home_page/plant.png',
                                width: 24.w,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Human-readable recurrence: the habit's weekdays or the action's date,
  /// each with the scheduled time when set.
  String _recurrenceLabel(AppLocalizations l10n) {
    final time = routine.scheduledMinute;
    final timeStr = time == null
        ? null
        : '${(time ~/ 60).toString().padLeft(2, '0')}:'
              '${(time % 60).toString().padLeft(2, '0')}';

    final base = routine.type == RoutineType.habit
        ? _daysLabel(l10n)
        : (routine.scheduledDate != null
              ? _dateLabel(l10n, routine.scheduledDate!)
              : l10n.routineDetailAnytime);

    return timeStr == null ? base : '$base · $timeStr';
  }

  String _dateLabel(AppLocalizations l10n, DateTime d) =>
      '${localizedMonth(l10n, d.month)} ${d.day}, ${d.year}';

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

/// Circular tinted badge holding the routine's emoji, lifted onto the band.
class _EmojiBadge extends StatelessWidget {
  final String emoji;
  final Color tint;

  const _EmojiBadge({required this.emoji, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      height: 96.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: tint.withAlpha(80), blurRadius: 20),
        ],
      ),
      child: Text(emoji, style: TextStyle(fontSize: 44.sp)),
    );
  }
}

/// A labelled read-only card matching the routine form's card style.
class _DetailCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _DetailCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

/// Color band at the top with a back button.
class _HeaderBand extends StatelessWidget {
  final Color color;

  const _HeaderBand({required this.color});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      height: topInset + 120.h,
      padding: EdgeInsets.only(top: topInset + 8.h, left: 4.w),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16)),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: color,
          size: 20.sp,
        ),
        onPressed: withHaptic(() => Navigator.of(context).maybePop()),
      ),
    );
  }
}
