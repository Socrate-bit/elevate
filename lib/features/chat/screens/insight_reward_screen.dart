import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../widgets/insight_progress_button.dart';

/// Full-screen celebration shown the first time an insight is opened and closed.
/// Bursts confetti, springs the insight glyph into view, and reveals the earned
/// reward (XP + pieces) before a "Done" button dismisses it.
class InsightRewardScreen extends StatefulWidget {
  /// The reward granted (both the XP and the piece count shown to the user).
  final int xp;

  const InsightRewardScreen({super.key, required this.xp});

  @override
  State<InsightRewardScreen> createState() => _InsightRewardScreenState();
}

class _InsightRewardScreenState extends State<InsightRewardScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  // Spring-in of the glyph badge.
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // Staggered fade/slide-up of the reward text.
  late final AnimationController _text = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    // Celebrate immediately on entry.
    HapticFeedback.heavyImpact();
    _confetti.play();
    _burst.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _text.forward();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _burst.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _text, curve: Curves.easeOutCubic));

    return Scaffold(
      backgroundColor: c.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
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
                ChatPalette.accent,
                Color(0xFFFEB114),
                Color(0xFFEC5B3A),
                Color(0xFF1EA49A),
                Color(0xFFF03E3E),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Insight glyph springing into view over a soft accent glow.
                ScaleTransition(
                  scale: CurvedAnimation(parent: _burst, curve: Curves.elasticOut),
                  child: _GlyphBadge(),
                ),
                SizedBox(height: 28.h),
                FadeTransition(
                  opacity: _text,
                  child: SlideTransition(
                    position: slide,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.chatInsightRewardTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w900,
                              color: c.textPrimary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            l10n.chatInsightRewardBody,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              height: 1.4,
                              color: c.textSecondary,
                            ),
                          ),
                          SizedBox(height: 28.h),
                          // The two reward tokens.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _RewardChip(
                                icon: Icons.bolt_rounded,
                                label: l10n.chatInsightRewardXp(widget.xp),
                                color: ChatPalette.accent,
                              ),
                              SizedBox(width: 14.w),
                              _RewardChip(
                                icon: Icons.monetization_on_rounded,
                                label: l10n.chatInsightRewardPieces(widget.xp),
                                color: const Color(0xFFFEB114),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Dismiss button.
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
                  child: GestureDetector(
                    onTap: withMediumHaptic(() => Navigator.of(context).pop()),
                    child: Container(
                      width: double.infinity,
                      height: 54.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ChatPalette.accent,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        l10n.chatInsightRewardDone,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The insight glyph inside a filled accent disc with a radial glow.
class _GlyphBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.w,
      height: 200.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ChatPalette.accent.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 120.w,
            height: 120.w,
            decoration: const BoxDecoration(
              color: ChatPalette.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(kInsightIcon, size: 56.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// A pill showing one reward token (icon + label).
class _RewardChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22.w, color: color),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
