import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/journal_mock_data.dart';

/// Vertical list of journal-entry cards.
class JournalEntryList extends StatelessWidget {
  const JournalEntryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          for (final entry in JournalMockData.entries)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _EntryCard(entry: entry),
            ),
        ],
      ),
    );
  }
}

/// One journal entry as a white card: icon tile, texts, category chip, chevron.
class _EntryCard extends StatelessWidget {
  final JournalEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(() {}),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: HomePalette.cardWhite,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular icon tile.
            Container(
              width: 42.w,
              height: 42.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entry.tileColor,
                shape: BoxShape.circle,
              ),
              child: Text(entry.emoji, style: TextStyle(fontSize: 20.sp)),
            ),
            SizedBox(width: 12.w),
            // Title + subtitle + date.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: HomePalette.titleDark,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text('🌿', style: TextStyle(fontSize: 11.sp)),
                      SizedBox(width: 8.w),
                      _CategoryChip(category: entry.category),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.3,
                      color: HomePalette.subtitleGrey,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    entry.dateLabel,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: HomePalette.subtitleGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: HomePalette.subtitleGrey.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

/// Colored category pill (Conversation / Reflection / Win / Pattern).
class _CategoryChip extends StatelessWidget {
  final JournalCategory category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: category.chipBg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: category.chipText,
        ),
      ),
    );
  }
}
