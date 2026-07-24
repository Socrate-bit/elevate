import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../subscription/services/analytics_service.dart';
import '../../trophy/screens/trophies_grid_screen.dart';

/// Page header: the "Journal" title with a trophies-gallery shortcut on the right.
class JournalHeader extends StatelessWidget {
  const JournalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Text(
            l10n.journalTitle,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: HomePalette.headlineGreen,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: withHaptic(() {
              AnalyticsService.capture(AnalyticsService.trophiesOpened);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrophiesGridScreen()),
              );
            }),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 26.sp,
              color: HomePalette.headlineGreen,
            ),
          ),
        ],
      ),
    );
  }
}
