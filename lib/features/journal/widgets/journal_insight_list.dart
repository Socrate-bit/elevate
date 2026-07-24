import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../chat/screens/chat_page_screen.dart';
import '../../chat/screens/insight_detail_screen.dart';
import '../../chat/widgets/insight_progress_button.dart';
import '../../subscription/services/analytics_service.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../models/journal_insight.dart';

/// Vertical list of every generated insight (newest first). Each card opens the
/// full [InsightDetailScreen]. Shows an empty state when nothing has been
/// generated yet.
class JournalInsightList extends StatelessWidget {
  const JournalInsightList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: Center(
              child: CircularProgressIndicator(color: ChatPalette.accent),
            ),
          );
        }
        if (state.insights.isEmpty) {
          return const _JournalEmptyState();
        }
        // Rows inside the single white panel, split by hairline dividers.
        return Column(
          children: [
            for (var i = 0; i < state.insights.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: HomePalette.subtitleGrey.withValues(alpha: 0.12),
                ),
              _InsightCard(entry: state.insights[i]),
            ],
          ],
        );
      },
    );
  }
}

/// One insight as a row inside the white panel: icon tile, title, body preview,
/// date, chevron.
class _InsightCard extends StatelessWidget {
  final JournalInsight entry;

  const _InsightCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d, h:mm a').format(entry.createdAt);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: withHaptic(() {
        AnalyticsService.capture(AnalyticsService.chatInsightOpened);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InsightDetailScreen(insight: entry.insight),
          ),
        );
      }),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular insight icon tile.
            Container(
              width: 42.w,
              height: 42.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: HomePalette.tileGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(kInsightIcon, size: 20.sp, color: ChatPalette.accent),
            ),
            SizedBox(width: 12.w),
            // Title + body preview + date.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.insight.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: HomePalette.titleDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    entry.insight.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.3,
                      color: HomePalette.subtitleGrey,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    dateLabel,
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

/// Shown when the user hasn't generated any insights yet: a gentle message and
/// a button that opens the chat so they can start.
class _JournalEmptyState extends StatelessWidget {
  const _JournalEmptyState();

  void _openChat(BuildContext context) {
    AnalyticsService.capture(AnalyticsService.chatOpened);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatPage(fullScreen: true)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(32.w, 48.h, 32.w, 0),
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: HomePalette.tileGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(kInsightIcon, size: 34.sp, color: ChatPalette.accent),
          ),
          SizedBox(height: 20.h),
          Text(
            l10n.journalInsightsEmptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: HomePalette.titleDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.journalInsightsEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.4,
              color: HomePalette.subtitleGrey,
            ),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: withHaptic(() => _openChat(context)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: ChatPalette.accent,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Text(
                l10n.journalInsightsEmptyCta,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
