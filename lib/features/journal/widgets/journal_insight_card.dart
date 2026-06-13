import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../models/journal_mock_data.dart';

/// Cream card summarizing the month, with a sprout illustration and tag chips.
class JournalInsightCard extends StatelessWidget {
  const JournalInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: JournalPalette.insightCardBg,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header.
            Row(
              children: [
                Text('🌿', style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 6.w),
                Text(
                  l10n.journalMonthlyInsight,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.titleDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Body text + sprout illustration.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    JournalMockData.insightBody,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.4,
                      color: JournalPalette.insightBody,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Image.asset(
                  'assets/journal/pouce.png',
                  width: 64.w,
                  height: 64.w,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Theme tags.
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: JournalMockData.insightTags
                  .map((tag) => _InsightTag(tag: tag))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small rounded tag chip with an emoji and label.
class _InsightTag extends StatelessWidget {
  final JournalInsightTag tag;

  const _InsightTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: JournalPalette.tagBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.emoji, style: TextStyle(fontSize: 11.sp)),
          SizedBox(width: 5.w),
          Text(
            tag.label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: JournalPalette.tagText,
            ),
          ),
        ],
      ),
    );
  }
}
