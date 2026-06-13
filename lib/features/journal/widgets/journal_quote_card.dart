import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/journal_mock_data.dart';

/// Translucent sky-blue card holding the daily quote and its author.
class JournalQuoteCard extends StatelessWidget {
  const JournalQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: JournalPalette.quoteCardBg.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opening quote glyph.
            Text(
              '“',
              style: TextStyle(
                fontSize: 34.sp,
                height: 0.9,
                fontWeight: FontWeight.w800,
                color: JournalPalette.quoteGlyph,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    JournalMockData.quoteText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: HomePalette.textDarkGreen,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '— ${JournalMockData.quoteAuthor}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: HomePalette.textDarkGreen.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Heart button in a white circle.
            GestureDetector(
              onTap: withHaptic(() {}),
              child: Container(
                width: 30.w,
                height: 30.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  size: 16.sp,
                  color: HomePalette.badgeRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
