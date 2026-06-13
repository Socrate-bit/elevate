import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Page header: "Journal" title with an info glyph, and a settings gear.
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
          SizedBox(width: 6.w),
          Icon(
            Icons.info_outline_rounded,
            size: 16.sp,
            color: HomePalette.textDarkGreen.withValues(alpha: 0.6),
          ),
          const Spacer(),
          // Settings gear in a soft circle.
          GestureDetector(
            onTap: withHaptic(() {}),
            child: Container(
              width: 38.w,
              height: 38.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_rounded,
                size: 22.sp,
                color: HomePalette.textDarkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
