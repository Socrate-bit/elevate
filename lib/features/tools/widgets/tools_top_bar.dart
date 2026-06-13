import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Tools page top bar: "Tools" title + info dot on the left, settings gear on
/// the right.
class ToolsTopBar extends StatelessWidget {
  const ToolsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          Text(
            l10n.navTools,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: HomePalette.textDarkGreen,
            ),
          ),
          SizedBox(width: 6.w),
          Icon(
            Icons.info_outline_rounded,
            size: 16.sp,
            color: HomePalette.textDarkGreen.withValues(alpha: 0.55),
          ),
          const Spacer(),
          // Settings gear in a soft translucent circle.
          GestureDetector(
            onTap: withHaptic(() {}),
            child: Container(
              width: 38.w,
              height: 38.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_rounded,
                size: 22.sp,
                color: HomePalette.textDarkGreen.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
