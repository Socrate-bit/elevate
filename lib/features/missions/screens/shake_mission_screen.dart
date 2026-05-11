import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shake/shake.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../widgets/levio_brand_header.dart';
import '../widgets/mission_complete_screen.dart';

/// Standalone shake mission: shake the phone N times to complete.
class ShakeMissionScreen extends StatefulWidget {
  final int target;
  final VoidCallback? onComplete;
  final bool isPreview;

  const ShakeMissionScreen({
    super.key,
    this.target = 15,
    this.onComplete,
    this.isPreview = false,
  });

  @override
  State<ShakeMissionScreen> createState() => _ShakeMissionScreenState();
}

class _ShakeMissionScreenState extends State<ShakeMissionScreen> {
  int _shakeCount = 0;
  late final ShakeDetector _detector;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _detector = ShakeDetector.autoStart(
      shakeThresholdGravity: 1.5,
      shakeSlopTimeMS: 500,
      minimumShakeCount: 1,
      onPhoneShake: () => _onShake(),
    );
  }

  void _onShake() {
    if (_shakeCount >= widget.target) return;
    HapticFeedback.mediumImpact();
    setState(() => _shakeCount++);
    if (_shakeCount >= widget.target) _finish();
  }

  void _finish() {
    _detector.stopListening();
    if (widget.isPreview) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (widget.onComplete != null) {
      widget.onComplete!();
      return;
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MissionCompleteScreen()),
      );
    }
  }

  @override
  void dispose() {
    _detector.stopListening();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = _shakeCount / widget.target;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const LevioBrandHeader(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 220.w,
                            height: 220.h,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 12,
                                    backgroundColor: c.separator,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '$_shakeCount',
                                      style: TextStyle(
                                        color: c.textPrimary,
                                        fontSize: 64.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '/ ${widget.target}',
                                      style: TextStyle(color: c.textSecondary, fontSize: 22.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            l10n.dismissShakePrompt,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.sp, color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.isPreview)
              Positioned(
                top: 16.h, right: 16.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36.w, height: 36.h,
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: Icon(Icons.close, size: 18.sp, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
