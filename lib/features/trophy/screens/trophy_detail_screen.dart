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
/// title, the citation, its author/source, and the earned date. A black "Done"
/// button dismisses it. Theme-adaptive.
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
      body: SafeArea(
        child: Column(
          children: [
            // Centered, scrollable citation content.
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HexagonBadge(
                      size: 132.w,
                      color: color,
                      icon: trophyIcon(trophy.iconKey),
                    ),
                    if (trophy.title.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Text(
                        trophy.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: color,
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),
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
                      style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            // Black "Done" button pinned to the bottom.
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
              child: GestureDetector(
                onTap: withMediumHaptic(() => Navigator.of(context).maybePop()),
                child: Container(
                  width: double.infinity,
                  height: 52.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    l10n.trophyDetailDone,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
