import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../models/community_seed.dart';

/// Peach inspiration card: shiba illustration + quote of the day.
class DailyInspirationCard extends StatelessWidget {
  const DailyInspirationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: CommunityPalette.inspirationCard,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Illustration.
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.asset(
              'assets/community/shiba_nature.png',
              width: 88.w,
              height: 88.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          // Quote + label.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        CommunitySeed.dailyInspiration,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: CommunityPalette.textDark,
                        ),
                      ),
                    ),
                    Text('✨', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.communityDailyInspiration,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: CommunityPalette.textBrown,
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
