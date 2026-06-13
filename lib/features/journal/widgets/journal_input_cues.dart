import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/journal_mock_data.dart';

/// "Input Cues" section: a header followed by a row of prompt cards.
class JournalInputCues extends StatelessWidget {
  const JournalInputCues({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header.
          Row(
            children: [
              Text('✏️', style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 6.w),
              Text(
                l10n.journalInputCues,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: HomePalette.titleDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Three prompt cards side by side.
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < JournalMockData.cues.length; i++) ...[
                if (i > 0) SizedBox(width: 10.w),
                Expanded(child: _CueCard(cue: JournalMockData.cues[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Single white prompt card with an icon and question.
class _CueCard extends StatelessWidget {
  final JournalCue cue;

  const _CueCard({required this.cue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(() {}),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: HomePalette.cardWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cue.emoji, style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 8.h),
            Text(
              cue.question,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                height: 1.25,
                color: HomePalette.titleDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
