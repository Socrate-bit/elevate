import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../widgets/mission_complete_screen.dart';

enum _BreathingPhase { inhale, holdIn, exhale, holdOut }

/// Guided box-breathing mission. An inner circle grows on inhale, holds at
/// max during the first hold, shrinks on exhale, and holds at min during the
/// second hold. Repeats [rounds] times.
class BreathingMissionScreen extends StatefulWidget {
  final int inhaleDurationMs;
  final int holdAfterInhaleDurationMs;
  final int exhaleDurationMs;
  final int holdAfterExhaleDurationMs;
  final int rounds;
  final VoidCallback? onComplete;
  final bool isPreview;

  const BreathingMissionScreen({
    super.key,
    this.inhaleDurationMs = 4000,
    this.holdAfterInhaleDurationMs = 4000,
    this.exhaleDurationMs = 4000,
    this.holdAfterExhaleDurationMs = 4000,
    this.rounds = 3,
    this.onComplete,
    this.isPreview = false,
  });

  @override
  State<BreathingMissionScreen> createState() => _BreathingMissionScreenState();
}

class _BreathingMissionScreenState extends State<BreathingMissionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  _BreathingPhase _phase = _BreathingPhase.inhale;
  int _round = 0;
  Timer? _holdTimer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_onAnimationStatus);
    _startPhase(_BreathingPhase.inhale);
  }

  void _startPhase(_BreathingPhase phase) {
    if (!mounted || _finished) return;
    setState(() => _phase = phase);
    HapticFeedback.lightImpact();

    switch (phase) {
      case _BreathingPhase.inhale:
        _controller.duration = Duration(milliseconds: widget.inhaleDurationMs);
        _controller.forward(from: 0.0);
        break;
      case _BreathingPhase.exhale:
        _controller.duration = Duration(milliseconds: widget.exhaleDurationMs);
        _controller.reverse(from: 1.0);
        break;
      case _BreathingPhase.holdIn:
        _controller.value = 1.0;
        _holdTimer = Timer(
          Duration(milliseconds: widget.holdAfterInhaleDurationMs),
          _advanceFromHold,
        );
        break;
      case _BreathingPhase.holdOut:
        _controller.value = 0.0;
        _holdTimer = Timer(
          Duration(milliseconds: widget.holdAfterExhaleDurationMs),
          _advanceFromHold,
        );
        break;
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (!mounted || _finished) return;
    if (_phase == _BreathingPhase.inhale && status == AnimationStatus.completed) {
      _startPhase(_BreathingPhase.holdIn);
    } else if (_phase == _BreathingPhase.exhale &&
        status == AnimationStatus.dismissed) {
      _startPhase(_BreathingPhase.holdOut);
    }
  }

  void _advanceFromHold() {
    if (!mounted || _finished) return;
    if (_phase == _BreathingPhase.holdIn) {
      _startPhase(_BreathingPhase.exhale);
    } else if (_phase == _BreathingPhase.holdOut) {
      final next = _round + 1;
      if (next >= widget.rounds) {
        _finish();
        return;
      }
      setState(() => _round = next);
      _startPhase(_BreathingPhase.inhale);
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _holdTimer?.cancel();
    _controller.stop();
    HapticFeedback.mediumImpact();

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
    _holdTimer?.cancel();
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  String _phaseLabel(AppLocalizations l10n) {
    switch (_phase) {
      case _BreathingPhase.inhale:
        return l10n.breathingPhaseInhale;
      case _BreathingPhase.exhale:
        return l10n.breathingPhaseExhale;
      case _BreathingPhase.holdIn:
      case _BreathingPhase.holdOut:
        return l10n.breathingPhaseHold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _phaseLabel(l10n),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: 260.w,
                    height: 260.w,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (_, _) => CustomPaint(
                        painter: _BreathingPainter(
                          progress: _controller.value,
                          outerColor: c.primary,
                          innerColor: c.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    l10n.breathingRoundLabel(_round + 1, widget.rounds),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isPreview)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
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

class _BreathingPainter extends CustomPainter {
  final double progress;
  final Color outerColor;
  final Color innerColor;

  _BreathingPainter({
    required this.progress,
    required this.outerColor,
    required this.innerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.shortestSide / 2 - 4;
    final minInner = outerRadius * 0.25;
    final maxInner = outerRadius * 0.95;
    final innerRadius = lerpDouble(minInner, maxInner, progress)!;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = outerColor.withAlpha(80);
    canvas.drawCircle(center, outerRadius, ringPaint);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = innerColor.withAlpha(60);
    canvas.drawCircle(center, innerRadius, fillPaint);
  }

  @override
  bool shouldRepaint(_BreathingPainter old) =>
      progress != old.progress ||
      outerColor != old.outerColor ||
      innerColor != old.innerColor;
}
