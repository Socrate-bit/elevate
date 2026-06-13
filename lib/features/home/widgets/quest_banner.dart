import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/home_mock_data.dart';

/// Teal quest banner with lightning icon, title and progress pill.
class QuestBanner extends StatelessWidget {
  const QuestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const done = HomeMockData.questDone;
    const total = HomeMockData.questTotal;

    return Padding(
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
