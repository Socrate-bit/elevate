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

/// Full-page modal for the daily streak, opened by tapping the streak counter on
/// the home page. Mirrors the milestones design: the current/best streak record
/// cards, a current → next badge card with progress, and the full badge grid.
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
            // Header — close button.
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
                      // Series record — current / best streak.
                      Row(
                        children: [
                          Expanded(
                            child: _StreakStatCard(
                              icon: Image.asset(
                                'assets/home_page/streak.png',
                                width: 56.w,
                                height: 56.w,
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
                                width: 56.w,
                                height: 56.w,
                              ),
                              value: '${state.bestStreak}',
                              label: l10n.streakBestLabel,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      // Current → next badge.
                      _NextBadgeCard(
                        streak: state.streak,
                        bestStreak: state.bestStreak,
                      ),
                      SizedBox(height: 24.h),
                      // All badges.
                      Text(
                        l10n.milestonesStreakBadges,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _BadgeGrid(bestStreak: state.bestStreak),
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

/// One of the two top record cards (current / best streak). Square, with the
/// icon centered above a large value and its label.
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
    return AspectRatio(
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
            SizedBox(height: 56.w, child: Center(child: icon)),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
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
      ),
    );
  }
}

/// Highlights the badge the current streak is working toward: the earned
/// "current" badge on the left, the locked "next" badge on the right, a
/// progress bar between them and the next badge's inspirational quote. Falls
/// back to a celebratory state once every milestone has been reached.
class _NextBadgeCard extends StatelessWidget {
  final int streak;
  final int bestStreak;

  const _NextBadgeCard({required this.streak, required this.bestStreak});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Highest badge already earned (by best streak), and the next to earn.
    StreakMilestone? current;
    for (final m in kStreakMilestones) {
      if (bestStreak >= m.days) current = m;
    }
    final next = nextStreakMilestone(streak);

    // All milestones reached — celebrate the final badge and its quote.
    if (next == null) {
      final last = kStreakMilestones.last;
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
                _BadgeThumb(asset: last.asset, earned: true, size: 64.w),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardLabel(l10n.streakAllMilestonesReached),
                      SizedBox(height: 2.h),
                      Text(
                        localizedStreakBadgeName(l10n, last.days),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _Quote(localizedStreakBadgeQuote(l10n, last.days)),
          ],
        ),
      );
    }

    // Progress within the current band (previous milestone → next).
    final prevDays = kStreakMilestones
        .map((m) => m.days)
        .where((d) => d <= streak)
        .fold<int>(0, (a, b) => b > a ? b : a);
    final span = next.days - prevDays;
    final progress =
        span <= 0 ? 0.0 : ((streak - prevDays) / span).clamp(0.0, 1.0);

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
              // Current earned badge (locked placeholder if none yet).
              _BadgeThumb(
                asset: (current ?? kStreakMilestones.first).asset,
                earned: current != null,
                size: 56.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardLabel(l10n.streakNextBadge),
                    SizedBox(height: 2.h),
                    Text(
                      localizedStreakBadgeName(l10n, next.days),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.streakDaysToGo(next.days - streak),
                      style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Next badge, dimmed until earned.
              _BadgeThumb(asset: next.asset, earned: false, size: 56.w),
            ],
          ),
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
          SizedBox(height: 14.h),
          _Quote(localizedStreakBadgeQuote(l10n, next.days)),
        ],
      ),
    );
  }
}

/// The full set of streak badges in a 3-column grid, each dimmed until its
/// milestone is earned (best streak reaches the required days).
class _BadgeGrid extends StatelessWidget {
  final int bestStreak;

  const _BadgeGrid({required this.bestStreak});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.8,
      ),
      itemCount: kStreakMilestones.length,
      itemBuilder: (ctx, i) {
        final m = kStreakMilestones[i];
        final earned = bestStreak >= m.days;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BadgeThumb(asset: m.asset, earned: earned, size: 100.w),
            SizedBox(height: 8.h),
            Text(
              localizedStreakBadgeName(l10n, m.days),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: earned ? c.textPrimary : c.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${m.days}',
              style: TextStyle(fontSize: 10.sp, color: c.textSecondary),
            ),
          ],
        );
      },
    );
  }
}

/// A streak badge image, shown at full strength when earned and dimmed when
/// still locked.
class _BadgeThumb extends StatelessWidget {
  final String asset;
  final bool earned;
  final double size;

  const _BadgeThumb({
    required this.asset,
    required this.earned,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.3,
      child: Image.asset(asset, width: size, height: size),
    );
  }
}

/// Small uppercase-yellow caption used above a card's title.
class _CardLabel extends StatelessWidget {
  final String text;

  const _CardLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: HomePalette.progressYellow,
        letterSpacing: 0.3,
      ),
    );
  }
}

/// Italic inspirational quote shown at the bottom of a badge card.
class _Quote extends StatelessWidget {
  final String text;

  const _Quote(this.text);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontStyle: FontStyle.italic,
        color: c.textSecondary,
        height: 1.4,
      ),
    );
  }
}
