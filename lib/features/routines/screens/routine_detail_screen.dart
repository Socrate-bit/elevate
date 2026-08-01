import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../adventure/cubit/adventure_cubit.dart';
import '../../tools/models/tools_mock_data.dart';
import '../../tools/tools_launcher.dart';
import '../cubit/routine_cubit.dart';
import '../models/routine.dart';
import '../models/routine_palette.dart';

/// Read-only detail view for a single [Routine], opened when a task is tapped
/// from the plan. Shows, top to bottom: the emoji, the title, the recurrence
/// detail, the description, and the reward. Theme-adaptive. Activities that
/// aren't validated yet also get a "Start now" button that runs their session.
class RoutineDetailScreen extends StatelessWidget {
  final Routine routine;

  /// Whether the routine is already validated for today (hides "Start now").
  final bool done;

  const RoutineDetailScreen({
    super.key,
    required this.routine,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tint = routineColor(routine.colorKey);
    final description = routine.description?.trim();
    // Activity/tool task with a guided session that hasn't been done yet.
    final tool =
        routine.toolKey == null ? null : ToolsMockData.byKey(routine.toolKey!);
    final canStart = tool != null && tool.hasSession && !done;

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
                        // Activities: start the guided session straight away.
                        if (canStart) ...[
                          SizedBox(height: 24.h),
                          _StartNowButton(
                            color: tint,
                            label: l10n.routineDetailStartNow,
                            onTap: () => _startNow(context, tool),
                          ),
                        ],
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

  /// Runs the activity's guided session; validates + rewards the routine and
  /// returns to the plan once the session runs to completion.
  Future<void> _startNow(BuildContext context, ToolItem tool) async {
    // Capture what we need before the await so we don't touch a stale context.
    final routineCubit = context.read<RoutineCubit>();
    final adventure = context.read<AdventureCubit>();
    final navigator = Navigator.of(context);
    final completed = await openToolSession(context, tool);
    if (!completed) return;
    await routineCubit.validate(routine.id);
    // Award coins (== the task's XP) + a strike; fires confetti on home.
    await adventure.awardForCompletion(routine.xp);
    navigator.pop();
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

/// Full-width tinted call-to-action that starts an activity's session.
class _StartNowButton extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _StartNowButton({
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withMediumHaptic(onTap),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
