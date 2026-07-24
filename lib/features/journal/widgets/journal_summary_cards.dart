import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../chat/widgets/insight_progress_button.dart';
import '../../subscription/services/analytics_service.dart';
import '../../trophy/cubit/trophies_cubit.dart';
import '../../trophy/cubit/trophies_state.dart';
import '../../trophy/screens/trophies_grid_screen.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';

/// The two summary tiles at the top of the Journal: a live count of generated
/// insights and a live count of earned wisdom. The wisdom tile opens the
/// [TrophiesGridScreen].
class JournalSummaryCards extends StatelessWidget {
  const JournalSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Insights count.
        Expanded(
          child: BlocBuilder<JournalCubit, JournalState>(
            buildWhen: (a, b) => a.insights.length != b.insights.length,
            builder: (context, state) => _SummaryCard(
              icon: kInsightIcon,
              count: state.insights.length,
              label: l10n.journalInsightsLabel,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Wisdom count — taps through to the trophies gallery.
        Expanded(
          child: BlocBuilder<TrophiesCubit, TrophiesState>(
            buildWhen: (a, b) => a.trophies.length != b.trophies.length,
            builder: (context, state) => _SummaryCard(
              icon: Icons.emoji_events_rounded,
              count: state.trophies.length,
              label: l10n.journalWisdomLabel,
              onTap: withHaptic(() {
                AnalyticsService.capture(AnalyticsService.trophiesOpened);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TrophiesGridScreen(),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

/// One translucent stat tile floating over the forest: icon + big count + label,
/// with a chevron affordance when it is tappable.
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: HomePalette.cardWhite,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: HomePalette.tileGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20.sp, color: ChatPalette.accent),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22.sp,
                    color: HomePalette.subtitleGrey.withValues(alpha: 0.6),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.titleDark,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: HomePalette.subtitleGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
