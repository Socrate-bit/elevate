import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../services/chat_insight.dart';
import '../widgets/insight_progress_button.dart';

/// Full-screen reader for a single [ChatInsight]: title, a key citation from the
/// conversation, and the insight paragraphs. Theme-adaptive.
class InsightDetailScreen extends StatelessWidget {
  final ChatInsight insight;

  const InsightDetailScreen({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final paragraphs = insight.body
        .split(RegExp(r'\n\s*\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          // Soft accent header band with a back button.
          SliverToBoxAdapter(child: _HeaderBand()),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title.
                  Text(
                    insight.title,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: c.textPrimary,
                    ),
                  ),
                  if (insight.quote.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    _QuoteBlock(quote: insight.quote),
                  ],
                  SizedBox(height: 24.h),
                  // Body paragraphs.
                  for (final p in paragraphs) ...[
                    Text(
                      p,
                      style: TextStyle(
                        fontSize: 17.sp,
                        height: 1.5,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: 18.h),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The colored band at the top with the back button, echoing the chat scene.
class _HeaderBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      height: topInset + 96.h,
      padding: EdgeInsets.only(top: topInset + 8.h, left: 4.w),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        color: ChatPalette.accent.withValues(alpha: 0.16),
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: ChatPalette.headerTitle,
          size: 20.sp,
        ),
        onPressed: withHaptic(() => Navigator.of(context).maybePop()),
      ),
    );
  }
}

/// Left-ruled citation block with a quote glyph, matching the reference design.
class _QuoteBlock extends StatelessWidget {
  final String quote;

  const _QuoteBlock({required this.quote});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 3.w, color: c.separator),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              quote,
              style: TextStyle(
                fontSize: 19.sp,
                height: 1.4,
                color: c.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(kInsightIcon, size: 18.sp, color: c.textSecondary),
        ],
      ),
    );
  }
}
