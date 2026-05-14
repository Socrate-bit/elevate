import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';
import '../../../shared/utils/haptic_utils.dart';

import '../../../shared/theme/app_theme.dart';
import '../../mood/models/mood_entry.dart';
import '../widgets/hexagon_badge.dart';
import '../../milestones/screens/milestones_screen.dart';
import '../../activity/models/activity.dart';
import '../cubit/insights_cubit.dart';
import '../cubit/insights_state.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => InsightsCubit(),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<InsightsCubit, InsightsState>(
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            bottom: false,
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.insightsTitle,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: c.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _RangeToggle(
                          selected: state.range,
                          onChanged: (r) =>
                              ctx.read<InsightsCubit>().changeRange(r),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: _StreakCard(
                                streak: state.currentStreak,
                                onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => const MilestonesScreen(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _BadgesCard(
                                earned: state.badgesEarned,
                                total: state.totalBadges,
                                onTap: () => Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => const MilestonesScreen(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 22.h),
                        Text(
                          l10n.insightsStats,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: c.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _StatCard(
                              icon: Icons.access_time_outlined,
                              label: l10n.insightsAvgTime,
                              value: state.avgTime,
                            ),
                            SizedBox(width: 12.w),
                            _StatCard(
                              icon: Icons.timer_outlined,
                              label: l10n.insightsAvgDuration,
                              value: state.avgDuration,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          l10n.moodSectionTitle,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: c.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _MoodCalendar(
                          range: state.range,
                          moodsByDay: state.moodsByDay,
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          l10n.activityHistoryTitle,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: c.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        if (state.activities.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: Text(
                                l10n.activityHistoryEmpty,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ...state.activities.asMap().entries.map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: _ActivityTile(activity: entry.value),
                                ),
                              ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _RangeToggle extends StatelessWidget {
  final InsightsRange selected;
  final ValueChanged<InsightsRange> onChanged;

  const _RangeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      InsightsRange.week: l10n.insightsWeek,
      InsightsRange.month: l10n.insightsMonth,
      InsightsRange.allTime: l10n.insightsAllTime,
    };
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: InsightsRange.values.map((r) {
          final isSelected = selected == r;
          return Expanded(
            child: GestureDetector(
              onTap: withHaptic(() => onChanged(r)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? c.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  labels[r]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : c.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  final VoidCallback onTap;

  const _StreakCard({required this.streak, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department_rounded,
                  size: 56.sp, color: c.primary),
              SizedBox(height: 4.h),
              Text(
                '$streak',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
              Text(
                l10n.insightsDayStreak,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgesCard extends StatelessWidget {
  final int earned;
  final int total;
  final VoidCallback onTap;

  const _BadgesCard({
    required this.earned,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HexagonBadge(
                label: '$earned',
                earned: earned > 0,
                size: 64.w,
                earnedColor: c.primary,
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.insightsBadgesEarned,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              if (earned > 0)
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    '$earned/$total',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: c.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14.sp, color: c.textSecondary),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: c.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodCalendar extends StatelessWidget {
  final InsightsRange range;
  final Map<DateTime, MoodValue> moodsByDay;

  const _MoodCalendar({required this.range, required this.moodsByDay});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    if (range == InsightsRange.week) {
      return _buildWeekStrip(context, c, l10n, now);
    } else {
      return _buildGrid(context, c, now);
    }
  }

  Widget _buildWeekStrip(
    BuildContext context,
    AppColors c,
    AppLocalizations l10n,
    DateTime now,
  ) {
    final daysFromSunday = now.weekday % 7;
    final sunday = DateTime(now.year, now.month, now.day - daysFromSunday);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final day = sunday.add(Duration(days: i));
          final normalized = DateTime(day.year, day.month, day.day);
          final mood = moodsByDay[normalized];
          final label = localizedDayShort(l10n, i);
          final isFuture = normalized.isAfter(DateTime(now.year, now.month, now.day));

          return Column(
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: c.textSecondary),
              ),
              SizedBox(height: 6.h),
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: mood != null ? mood.color.withAlpha(40) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: mood != null
                        ? mood.color
                        : c.separator,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isFuture
                      ? null
                      : mood != null
                          ? Text(mood.emoji, style: TextStyle(fontSize: 16.sp))
                          : Text(
                              '—',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: c.textSecondary.withAlpha(80),
                              ),
                            ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, AppColors c, DateTime now) {
    // Build a list of days to display
    final DateTime start;
    if (range == InsightsRange.month) {
      start = DateTime(now.year, now.month, 1);
    } else {
      // All time: last 90 days
      start = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 89));
    }

    // Align start to Sunday
    final offset = start.weekday % 7; // days after the preceding Sunday
    final gridStart = start.subtract(Duration(days: offset));

    final end = range == InsightsRange.month
        ? DateTime(now.year, now.month + 1, 0) // last day of month
        : DateTime(now.year, now.month, now.day);

    final totalDays = end.difference(gridStart).inDays + 1;
    final weeks = (totalDays / 7).ceil();

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day-of-week header
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: c.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 6.h),
          ...List.generate(weeks, (week) {
            return Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                children: List.generate(7, (day) {
                  final date = gridStart.add(Duration(days: week * 7 + day));
                  final normalized = DateTime(date.year, date.month, date.day);
                  final inRange = !date.isBefore(start) && !date.isAfter(end);
                  final isFuture =
                      normalized.isAfter(DateTime(now.year, now.month, now.day));
                  final mood = inRange ? moodsByDay[normalized] : null;

                  return Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: !inRange
                              ? Colors.transparent
                              : mood != null
                                  ? mood.color.withAlpha(50)
                                  : c.separator.withAlpha(80),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: inRange && !isFuture
                              ? mood != null
                                  ? Text(mood.emoji,
                                      style: TextStyle(fontSize: 12.sp))
                                  : Text(
                                      '—',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: c.textSecondary.withAlpha(60),
                                      ),
                                    )
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ts = activity.timestamp;
    final h = ts.hour > 12 ? ts.hour - 12 : (ts.hour == 0 ? 12 : ts.hour);
    final isPM = ts.hour >= 12;
    final timeStr =
        '$h:${ts.minute.toString().padLeft(2, '0')} ${isPM ? 'pm' : 'am'}';
    final dateStr = '${localizedMonth(l10n, ts.month)} ${ts.day}';

    final mins = activity.durationSeconds ~/ 60;
    final secs = activity.durationSeconds % 60;
    final durationStr = mins > 0 ? '${mins}m ${secs}s' : '${secs}s';

    final missed = !activity.completed;
    final iconColor = missed ? c.textSecondary : c.primary;
    final iconBg =
        missed ? c.textSecondary.withAlpha(20) : c.primary.withAlpha(25);

    return Opacity(
      opacity: missed ? 0.6 : 1.0,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                missed ? Icons.alarm_off_outlined : Icons.check_circle_outline,
                color: iconColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    missed ? l10n.activityHistoryMissed : activity.type,
                    style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                ),
                SizedBox(height: 2.h),
                if (!missed)
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 12.sp, color: c.textSecondary),
                      SizedBox(width: 3.w),
                      Text(
                        durationStr,
                        style: TextStyle(
                            fontSize: 12.sp, color: c.textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
