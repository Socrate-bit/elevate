import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../data/wisdom_trophies.dart';

/// Full-screen celebration shown when the pet returns from an adventure:
/// confetti, the earned trophy and a wise sentence.
class AdventureSuccessScreen extends StatefulWidget {
  final WisdomTrophy trophy;

  const AdventureSuccessScreen({super.key, required this.trophy});

  @override
  State<AdventureSuccessScreen> createState() => _AdventureSuccessScreenState();
}

class _AdventureSuccessScreenState extends State<AdventureSuccessScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 4));

  @override
  void initState() {
    super.initState();
    _confetti.play();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Warm celebratory gradient.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF8F0), Color(0xFFFFF0DC)],
              ),
            ),
          ),
          // Confetti bursts from the top center.
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 24,
              maxBlastForce: 22,
              minBlastForce: 8,
              gravity: 0.25,
              emissionFrequency: 0.04,
              colors: const [
                Color(0xFFFEB114),
                Color(0xFFEC5B3A),
                Color(0xFF1EA49A),
                Color(0xFF76A93F),
                Color(0xFFF03E3E),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: GestureDetector(
                    onTap: withHaptic(() => Navigator.pop(context)),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: const Color(0xFF3D2B1F),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy with a soft glow.
                      Container(
                        width: 200.w,
                        height: 200.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFEB114).withAlpha(70),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          widget.trophy.emoji,
                          style: TextStyle(fontSize: 96.sp),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        l10n.adventureSuccessLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: const Color(0xFFE05C1A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    widget.trophy.sentence,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF6B5540),
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 64.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
