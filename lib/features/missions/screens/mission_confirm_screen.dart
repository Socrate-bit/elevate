import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/mission.dart';
import '../models/mission_config.dart';
import 'mission_sequence_screen.dart';

/// Focused confirmation screen shown when the AI chat suggests a mission.
/// Displays the proposed mission and launches it directly on confirm.
class MissionConfirmScreen extends StatelessWidget {
  final MissionType missionType;

  const MissionConfirmScreen({super.key, required this.missionType});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final info = missionInfoFor(missionType);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 20.sp, color: c.textPrimary),
          onPressed: withHaptic(() => Navigator.of(context).pop()),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: info.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(info.icon, color: info.iconColor, size: 36.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                info.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                info.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: c.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: withMediumHaptic(() {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MissionSequenceScreen(
                        missions: [MissionConfig(type: missionType)],
                      ),
                    ),
                  );
                }),
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.chatMissionSetUp,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
