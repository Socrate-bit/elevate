import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/home_page_cubit.dart';
import '../cubit/home_page_state.dart';
import '../models/home_mock_data.dart';

/// Teal quest banner with lightning icon, title and progress pill. The shop and
/// quest shortcuts perch on the banner's top-right corner.
class QuestBanner extends StatelessWidget {
  const QuestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const done = HomeMockData.questDone;
    const total = HomeMockData.questTotal;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 18.w, left: 18.w, bottom: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              const _StreakSign(),
              SizedBox(width: 24.w),
              _PerchIcon(asset: 'assets/home_page/shop_icon.png', onTap: () {}),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: GestureDetector(
            onTap: withHaptic(() {}),
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
              decoration: BoxDecoration(
                // Just opacity — a translucent overlay over the green background.
                color: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Image.asset('assets/home/light.png', width: 38.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HomeMockData.questTitle,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _ProgressPill(
                          progress: total == 0 ? 0 : done / total,
                          label: l10n.homePageQuestProgress(done, total),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular shortcut icon that sits on top of the quest banner.
class _PerchIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _PerchIcon({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Image.asset(asset, width: 40.w, height: 40.w),
    );
  }
}

/// Streak sign perched on the banner: the flame asset with the live streak
/// count. Reads the count from [HomePageCubit], kept reactive to profile updates.
class _StreakSign extends StatelessWidget {
  const _StreakSign();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageCubit, HomePageState>(
      buildWhen: (a, b) => a.currentStreak != b.currentStreak,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/home_page/streak_icon.png',
              width: 40.w,
              height: 40.w,
            ),
            SizedBox(width: 4.w),
            Text(
              '${state.currentStreak}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// White pill progress bar with a yellow fill and centered label.
class _ProgressPill extends StatelessWidget {
  final double progress;
  final String label;

  const _ProgressPill({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Yellow fill — keeps a visible rounded nub even at 0 progress.
          FractionallySizedBox(
            widthFactor: (progress).clamp(0.07, 1.0),
            child: Container(
              margin: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: HomePalette.progressYellow,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
          ),
          Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.progressBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
