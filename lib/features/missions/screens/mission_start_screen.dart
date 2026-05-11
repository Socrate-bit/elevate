import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../levio/missions/models/mission.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Interstitial shown before each mission in a sequence.
class MissionStartScreen extends StatelessWidget {
  final int currentIndex;
  final int totalMissions;
  final MissionType missionType;
  final VoidCallback onStart;

  const MissionStartScreen({
    super.key,
    required this.currentIndex,
    required this.totalMissions,
    required this.missionType,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final info = missionInfoFor(missionType);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(color: info.iconBg, shape: BoxShape.circle),
              child: Icon(info.icon, color: info.iconColor, size: 36.sp),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                l10n.dismissMissionTimeToWakeUp,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textPrimary, fontSize: 28.sp, fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.dismissMissionLabel(currentIndex + 1, totalMissions, info.name),
              style: TextStyle(color: c.textSecondary, fontSize: 16.sp),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ElevatedButton(
                onPressed: withHaptic(onStart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 54.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: Text(
                  l10n.dismissStartMission,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalMissions, (i) {
                return Container(
                  width: 8.w, height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == currentIndex ? c.textPrimary : c.textSecondary.withAlpha(80),
                  ),
                );
              }),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
