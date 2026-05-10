import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

/// Auto-advances after a short delay. Shows a generic "Preparing your app…"
/// progress UI as a moment of anticipation before the paywall.
class LoadingStep extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;

  const LoadingStep({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<LoadingStep> createState() => _LoadingStepState();
}

class _LoadingStepState extends State<LoadingStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_completed) {
          _completed = true;
          widget.onComplete();
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          const Spacer(),
          Text(
            l10n.onboardingLoadingTitle,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => SizedBox(
              width: 220.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: LinearProgressIndicator(
                  value: _ctrl.value,
                  minHeight: 8.h,
                  backgroundColor: c.separator,
                  valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
