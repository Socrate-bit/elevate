import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Simple success screen shown after a standalone mission sequence finishes.
class MissionCompleteScreen extends StatelessWidget {
  const MissionCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.check_circle_outline_rounded,
                  size: 80.sp, color: AppColors.success),
              SizedBox(height: 24.h),
              Text(
                l10n.missionComplete,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.missionCompleteMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: c.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: withMediumHaptic(() => Navigator.of(context).popUntil((r) => r.isFirst)),
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: c.textPrimary,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: c.card,
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
