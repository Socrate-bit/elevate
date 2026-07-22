import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/appy_nav_bar.dart';

/// Quest page — placeholder for the upcoming quests feature. Hosted by the
/// shared AppyShell, so the bottom nav is driven by the shell's [AppNavCubit].
class QuestPage extends StatelessWidget {
  const QuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: JournalPalette.scrim,
      extendBody: true,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag_rounded,
                size: 48.sp,
                color: HomePalette.checkGreen,
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.questPageTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: HomePalette.headlineGreen,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.questPageComingSoon,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: HomePalette.subtitleGrey,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppyNavBar(),
    );
  }
}
