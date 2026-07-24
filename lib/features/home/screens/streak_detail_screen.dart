import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/streak_cubit.dart';
import '../cubit/streak_state.dart';
import '../models/streak_milestone.dart';

/// Detail screen for the daily streak, opened by tapping the streak counter on
/// the home page. Shows the current vs. best streak and the milestone the user
/// is working toward, with an inspirational quote.
class StreakDetailScreen extends StatelessWidget {
  const StreakDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — close button + title.
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: withHaptic(() => Navigator.pop(context)),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: c.card,
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(Icons.close, size: 18.sp, color: c.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<StreakCubit, StreakState>(
                builder: (context, state) => SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.streakTitle,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Current / best streak.
                      Row(
                        children: [
                          Expanded(
                            child: _StreakStatCard(
                              icon: Image.asset(
                                'assets/home_page/streak_icon.png',
                                width: 52.w,
                                height: 52.w,
                              ),
                              value: '${state.streak}',
                              label: l10n.streakCurrentLabel,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _StreakStatCard(
                              icon: Image.asset(
                                'assets/home_page/trophy.png',
                                width: 52.w,
                                height: 52.w,
                              ),
                              value: '${state.bestStreak}',
                              label: l10n.streakBestLabel,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // Milestones.
                      Text(
                        l10n.milestonesTitle,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _NextMilestoneCard(streak: state.streak),
                      SizedBox(height: 16.h),
                      _MilestoneRow(bestStreak: state.bestStreak),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the two top stat cards (current / best streak).
class _StreakStatCard extends StatelessWidget {
  final Widget icon;
  final String value;
  final String label;

  const _StreakStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          SizedBox(height: 52.w, child: Center(child: icon)),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlights the milestone the current streak is working toward, with a
/// progress bar and its inspirational quote. Falls back to a celebratory state
/// once every milestone has been reached.
class _NextMilestoneCard extends StatelessWidget {
  final int streak;

  const _NextMilestoneCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final next = nextStreakMilestone(streak);

    // All milestones reached — celebrate with the final badge and its quote.
    if (next == null) {
      const last = StreakMilestone(days: 365, asset: 'assets/streak_badges/365.png');
      return _MilestoneCardShell(
        asset: last.asset,
        title: l10n.streakAllMilestonesReached,
        subtitle: localizedStreakBadgeName(l10n, last.days),
        quote: localizedStreakBadgeQuote(l10n, last.days),
      );
    }

    // Progress within the current band (previous milestone → next).
    final prevDays = kStreakMilestones
        .map((m) => m.days)
        .where((d) => d <= streak)
        .fold<int>(0, (a, b) => b > a ? b : a);
    final span = next.days - prevDays;
    final progress = span <= 0 ? 0.0 : ((streak - prevDays) / span).clamp(0.0, 1.0);

    return _MilestoneCardShell(
      asset: next.asset,
      title: l10n.streakNextBadge,
      subtitle: localizedStreakBadgeName(l10n, next.days),
      quote: localizedStreakBadgeQuote(l10n, next.days),
      progress: progress,
      progressLabel: l10n.streakDaysToGo(next.days - streak),
    );
  }
}

/// Shared card layout for the milestone highlight (badge + copy + optional bar).
class _MilestoneCardShell extends StatelessWidget {
  final String asset;
  final String title;
  final String subtitle;
  final String quote;
  final double? progress;
  final String? progressLabel;

  const _MilestoneCardShell({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.quote,
    this.progress,
    this.progressLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(asset, width: 64.w, height: 64.w),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.progressYellow,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: c.textPrimary,
                      ),
                    ),
                    if (progressLabel != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        progressLabel!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            SizedBox(height: 14.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.h,
                backgroundColor: c.background,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  HomePalette.progressYellow,
                ),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          Text(
            quote,
            style: TextStyle(
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              color: c.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal row of every streak badge, dimmed until its milestone is earned
/// (best streak reaches the required days).
class _MilestoneRow extends StatelessWidget {
  final int bestStreak;

  const _MilestoneRow({required this.bestStreak});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final m in kStreakMilestones)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: bestStreak >= m.days ? 1.0 : 0.3,
                    child: Image.asset(m.asset, width: 56.w, height: 56.w),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${m.days}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: bestStreak >= m.days
                          ? c.textPrimary
                          : c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
