import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../subscription/services/analytics_service.dart';
import '../cubit/chat_cubit.dart';
import '../screens/insight_detail_screen.dart';
import '../screens/insight_reward_screen.dart';
import '../services/chat_message.dart';
import 'insight_progress_button.dart';

/// Inline card announcing a generated insight. Shows the insight title; tapping
/// opens the full [InsightDetailScreen]. The first open also grants a one-time
/// reward and, once the reader closes, celebrates it on the win page.
class ChatInsightCard extends StatelessWidget {
  final ChatMessage message;

  const ChatInsightCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final insight = message.insight!;

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: withHaptic(() => _openInsight(context)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.82.sw),
          margin: EdgeInsets.symmetric(vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            // Filled primary green so the insight stands out from the plain
            // chat bubbles; white content keeps it legible over the green.
            color: ChatPalette.accent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              topRight: Radius.circular(18.r),
              bottomLeft: Radius.circular(4.r),
              bottomRight: Radius.circular(18.r),
            ),
            boxShadow: [
              BoxShadow(
                color: ChatPalette.accent.withValues(alpha: 0.4),
                blurRadius: 14,
                spreadRadius: 1,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Insight" eyebrow with the glyph.
              Row(
                children: [
                  Icon(kInsightIcon, size: 16.sp, color: Colors.white),
                  SizedBox(width: 6.w),
                  Text(
                    l10n.chatInsightCardLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white.withValues(alpha: 0.85),
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
                  color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11.sp,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the reader; on the first-ever open, grants the reward and celebrates
  /// it on the win page once the reader is closed.
  Future<void> _openInsight(BuildContext context) async {
    final cubit = context.read<ChatCubit>();
    AnalyticsService.capture(AnalyticsService.chatInsightOpened);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InsightDetailScreen(insight: message.insight!),
      ),
    );
    if (!context.mounted) return;
    // Grant the one-time reward; only then show the celebration.
    final rewarded = await cubit.revealInsightReward(message.id);
    if (!rewarded || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const InsightRewardScreen(xp: ChatCubit.kInsightRewardXp),
      ),
    );
  }
}
