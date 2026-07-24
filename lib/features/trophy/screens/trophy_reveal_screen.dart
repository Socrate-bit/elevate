import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/trophy_reveal_cubit.dart';
import '../cubit/trophy_reveal_state.dart';
import '../data/trophy_badges.dart';
import '../models/trophy.dart';
import '../widgets/hexagon_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Full-screen reward reveal shown when the pet returns from an adventure.
/// While the citation is generated it plays an anticipation loop (a pulsing,
/// glowing hexagon); once ready it bursts the earned trophy into view with
/// confetti and a spring animation, then reveals the citation and author.
class TrophyRevealScreen extends StatefulWidget {
  const TrophyRevealScreen({super.key});

  @override
  State<TrophyRevealScreen> createState() => _TrophyRevealScreenState();
}

class _TrophyRevealScreenState extends State<TrophyRevealScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 4),
  );

  // Anticipation loop while generating.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  // Spring-in of the badge on reveal.
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // Staggered fade/slide-up of the citation text.
  late final AnimationController _text = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pulse.dispose();
    _burst.dispose();
    _text.dispose();
    super.dispose();
  }

  void _onRevealed() {
    _pulse.stop();
    _confetti.play();
    HapticFeedback.heavyImpact();
    _burst.forward();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _text.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrophyRevealCubit, TrophyRevealState>(
      listenWhen: (a, b) => a.phase != b.phase,
      listener: (context, state) {
        if (state.phase == TrophyRevealPhase.revealed) _onRevealed();
      },
      builder: (context, state) {
        final revealed =
            state.phase == TrophyRevealPhase.revealed && state.trophy != null;
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
              // Confetti bursts from the top center on reveal.
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Center(
                      child: revealed
                          ? _RevealedBadge(trophy: state.trophy!, burst: _burst)
                          : _GeneratingBadge(pulse: _pulse),
                    ),
                    SizedBox(height: 28.h),
                    // Eyebrow label + citation.
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: revealed
                          ? _Citation(trophy: state.trophy!, text: _text)
                          : _GeneratingLabel(),
                    ),
                    const Spacer(),
                    // Black "Done" button dismisses the reveal.
                    if (revealed)
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
                        child: GestureDetector(
                          onTap: withMediumHaptic(() => Navigator.pop(context)),
                          child: Container(
                            width: double.infinity,
                            height: 52.h,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.trophyDetailDone,
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
      },
    );
  }
}

/// Pulsing, glowing grey hexagon shown while the citation is being generated.
class _GeneratingBadge extends StatelessWidget {
  final AnimationController pulse;

  const _GeneratingBadge({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220.w,
      height: 220.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Slowly rotating conic glow ring.
          RotationTransition(
            turns: pulse,
            child: Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    const Color(0xFFFEB114).withValues(alpha: 0.0),
                    const Color(0xFFFEB114).withValues(alpha: 0.35),
                    const Color(0xFFEC5B3A).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Gently breathing grey hexagon.
          ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.04,
            ).animate(CurvedAnimation(parent: pulse, curve: Curves.easeInOut)),
            child: HexagonBadge(
              size: 140.w,
              color: const Color(0xFFCBBBA6),
              icon: Icons.auto_awesome,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Uncovering your wisdom…" label under the anticipation badge.
class _GeneratingLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: Text(
        l10n.trophyRevealGenerating,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6B5540),
        ),
      ),
    );
  }
}

/// The earned hexagon badge springing into view with a radial glow.
class _RevealedBadge extends StatelessWidget {
  final Trophy trophy;
  final AnimationController burst;

  const _RevealedBadge({required this.trophy, required this.burst});

  @override
  Widget build(BuildContext context) {
    final color = trophyColor(trophy.colorKey);
    return SizedBox(
      width: 240.w,
      height: 240.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial glow tinted to the badge color.
          FadeTransition(
            opacity: burst,
            child: Container(
              width: 240.w,
              height: 240.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withValues(alpha: 0.35), Colors.transparent],
                ),
              ),
            ),
          ),
          ScaleTransition(
            scale: CurvedAnimation(parent: burst, curve: Curves.elasticOut),
            child: HexagonBadge(
              size: 150.w,
              color: color,
              icon: trophyIcon(trophy.iconKey),
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Trophy Earned" eyebrow, the big citation, and its author, fading and
/// sliding up together after the badge lands.
class _Citation extends StatelessWidget {
  final Trophy trophy;
  final AnimationController text;

  const _Citation({required this.trophy, required this.text});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = trophyColor(trophy.colorKey);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: text, curve: Curves.easeOutCubic));
    final author = trophy.source.isEmpty
        ? trophy.author
        : '${trophy.author}, ${trophy.source}';

    return FadeTransition(
      opacity: text,
      child: SlideTransition(
        position: slide,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.wisdomUnlockedLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: const Color(0xFFE05C1A),
              ),
            ),
            if (trophy.title.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                trophy.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: color,
                ),
              ),
            ],
            SizedBox(height: 20.h),
            Text(
              '“${trophy.quote}”',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3D2B1F),
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '— $author',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B5540),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
