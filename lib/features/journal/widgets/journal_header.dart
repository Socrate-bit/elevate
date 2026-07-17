import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

/// Page header: just the "Journal" title.
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
        ],
      ),
    );
  }
}
