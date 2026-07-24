import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import 'breathing_mission_screen.dart';

/// Priming screen shown before the breathing animation. Explains the benefit
/// of deep breathing and starts the mission on tap. Forwards the breathing
/// configuration to [BreathingMissionScreen].
class BreathingIntroScreen extends StatelessWidget {
  final int inhaleDurationMs;
  final int holdAfterInhaleDurationMs;
  final int exhaleDurationMs;
  final int holdAfterExhaleDurationMs;
  final int rounds;
  final VoidCallback? onComplete;
  final bool isPreview;

  const BreathingIntroScreen({
    super.key,
    this.inhaleDurationMs = 4000,
    this.holdAfterInhaleDurationMs = 4000,
    this.exhaleDurationMs = 4000,
    this.holdAfterExhaleDurationMs = 4000,
    this.rounds = 3,
    this.onComplete,
    this.isPreview = false,
  });

  void _start(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BreathingMissionScreen(
          inhaleDurationMs: inhaleDurationMs,
          holdAfterInhaleDurationMs: holdAfterInhaleDurationMs,
          exhaleDurationMs: exhaleDurationMs,
          holdAfterExhaleDurationMs: holdAfterExhaleDurationMs,
          rounds: rounds,
          onComplete: onComplete,
          isPreview: isPreview,
        ),
      ),
    );
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Icon(Icons.self_improvement, size: 72.sp, color: c.primary),
              SizedBox(height: 32.h),
              Text(
                l10n.breathingIntroTitle,
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.breathingIntroDescription,
                style: TextStyle(
                  fontSize: 17.sp,
                  color: c.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: withHaptic(() => _start(context)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.breathingIntroStart,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(Icons.arrow_forward,
                          size: 20, color: Colors.white),
                    ],
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
