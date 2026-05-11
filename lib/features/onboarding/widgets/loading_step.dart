import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

/// Animated "Preparing your app…" step with a progress bar and a 6-row
/// task checklist. Auto-advances on completion. Replace [_stepLabels]
/// per-project with real labels.
class LoadingStep extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;

  const LoadingStep({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 7500),
  });

  @override
  State<LoadingStep> createState() => _LoadingStepState();
}

class _LoadingStepState extends State<LoadingStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;
  bool _completed = false;

  static const _stepCount = 6;

  List<String> _stepLabels(AppLocalizations l10n) => [
        l10n.onboardingLoadingStep1,
        l10n.onboardingLoadingStep2,
        l10n.onboardingLoadingStep3,
        l10n.onboardingLoadingStep4,
        l10n.onboardingLoadingStep5,
        l10n.onboardingLoadingStep6,
      ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progressAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_completed && mounted) {
        _completed = true;
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _completedCount(double progress) =>
      (progress * _stepCount).floor().clamp(0, _stepCount);

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, _) {
          final progress = _progressAnimation.value;
          final percent = (progress * 100).round();
          final completed = _completedCount(progress);
          final labels = _stepLabels(l10n);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 64.sp,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.onboardingLoadingTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: c.separator,
                    valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                    minHeight: 6,
                  ),
                ),
                SizedBox(height: 32.h),
                ...List.generate(_stepCount, (i) {
                  final done = i < completed;
                  final active = i == completed && completed < _stepCount;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: done
                              ? Icon(Icons.check_circle,
                                  size: 22.sp, color: c.primary)
                              : active
                                  ? SizedBox(
                                      width: 18.w,
                                      height: 18.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                c.primary),
                                      ),
                                    )
                                  : Icon(Icons.circle_outlined,
                                      size: 22.sp, color: c.separator),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: done || active
                                ? c.textPrimary
                                : c.textSecondary,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Spacer(flex: 3),
              ],
            ),
          );
        },
      ),
    );
  }
}
