import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/journal_mock_data.dart';

/// Soft pill showing the active date range, with a calendar icon and leaf.
class JournalDatePill extends StatelessWidget {
  const JournalDatePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: withHaptic(() {}),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16.sp,
                  color: HomePalette.textDarkGreen,
                ),
                SizedBox(width: 8.w),
                Text(
                  JournalMockData.dateRange,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: HomePalette.textDarkGreen,
                  ),
                ),
                SizedBox(width: 6.w),
                Text('🌿', style: TextStyle(fontSize: 12.sp)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
