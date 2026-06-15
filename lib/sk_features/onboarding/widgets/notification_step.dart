import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

class NotificationStep extends StatelessWidget {
  final VoidCallback onContinue;

  const NotificationStep({super.key, required this.onContinue});

  Future<void> _request() async {
    try {
      await Posthog().capture(eventName: 'onboarding_notification_request');
    } catch (_) {}
    onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Icon(Icons.notifications_active_rounded,
              size: 56.sp, color: c.primary),
          SizedBox(height: 16.h),
          Text(
            l10n.onboardingNotificationTitle,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.onboardingNotificationBody,
            style:
                TextStyle(fontSize: 16.sp, color: c.textSecondary, height: 1.5),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: withHaptic(_request),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(l10n.onboardingEnableNotifications,
                  style: TextStyle(fontSize: 16.sp)),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: GestureDetector(
              onTap: withHaptic(onContinue),
              child: Text(
                l10n.onboardingMaybeLater,
                style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
