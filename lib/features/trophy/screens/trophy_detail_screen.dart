import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../data/trophy_badges.dart';
import '../models/trophy.dart';
import '../widgets/hexagon_badge.dart';

/// Full-screen reader for a single earned [Trophy]: the badge, its one-word
/// title, the citation, its author/source, and the earned date. Theme-adaptive.
class TrophyDetailScreen extends StatelessWidget {
  final Trophy trophy;

  const TrophyDetailScreen({super.key, required this.trophy});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = trophyColor(trophy.colorKey);
    final l10n = AppLocalizations.of(context)!;
    final dateLabel = DateFormat('MMM d, yyyy').format(trophy.createdAt);

    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          // Color band tinted to the badge, with a back button.
          SliverToBoxAdapter(child: _HeaderBand(color: color)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Badge lifted onto the header band.
                  Transform.translate(
                    offset: Offset(0, -56.h),
                    child: HexagonBadge(
                      size: 112.w,
                      color: color,
                      icon: trophyIcon(trophy.iconKey),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -32.h),
                    child: Column(
                      children: [
                        if (trophy.title.isNotEmpty) ...[
                          Text(
                            trophy.title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: color,
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                        Text(
                          '“${trophy.quote}”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: c.textPrimary,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          trophy.source.isEmpty
                              ? '— ${trophy.author}'
                              : '— ${trophy.author}, ${trophy.source}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: c.textSecondary,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          l10n.trophyEarnedOn(dateLabel),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Color band at the top with a back button.
class _HeaderBand extends StatelessWidget {
  final Color color;

  const _HeaderBand({required this.color});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      height: topInset + 120.h,
      padding: EdgeInsets.only(top: topInset + 8.h, left: 4.w),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16)),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: color,
          size: 20.sp,
        ),
        onPressed: withHaptic(() => Navigator.of(context).maybePop()),
      ),
    );
  }
}
