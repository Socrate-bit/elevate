import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

/// Tools page top bar: just the "Tools" title.
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
        ],
      ),
    );
  }
}
