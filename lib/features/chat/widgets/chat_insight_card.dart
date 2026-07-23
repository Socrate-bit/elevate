import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../subscription/services/analytics_service.dart';
import '../screens/insight_detail_screen.dart';
import '../services/chat_insight.dart';
import 'insight_progress_button.dart';

/// Inline card announcing a generated insight. Shows the insight title; tapping
/// opens the full [InsightDetailScreen].
class ChatInsightCard extends StatelessWidget {
  final ChatInsight insight;

  const ChatInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: withHaptic(() {
          AnalyticsService.capture(AnalyticsService.chatInsightOpened);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InsightDetailScreen(insight: insight),
            ),
          );
        }),
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.82.sw),
          margin: EdgeInsets.symmetric(vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: ChatPalette.appyBubble,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              topRight: Radius.circular(18.r),
              bottomLeft: Radius.circular(4.r),
              bottomRight: Radius.circular(18.r),
            ),
            border: Border.all(color: ChatPalette.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Insight" eyebrow with the glyph.
              Row(
                children: [
                  Icon(kInsightIcon, size: 16.sp, color: ChatPalette.accent),
                  SizedBox(width: 6.w),
                  Text(
                    l10n.chatInsightCardLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: ChatPalette.accent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Insight title.
              Text(
                insight.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: ChatPalette.appyText,
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    l10n.chatInsightCardCta,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: ChatPalette.accent,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11.sp,
                    color: ChatPalette.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
