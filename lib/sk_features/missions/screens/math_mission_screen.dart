import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../models/mission_config.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/levio_brand_header.dart';
import '../widgets/mission_complete_screen.dart';

/// Standalone math mission: solve N problems of varying difficulty.
/// [onComplete] is called when done. If null and not preview, pushes [MissionCompleteScreen].
class MathMissionScreen extends StatefulWidget {
  final MathDifficulty difficulty;
  final int problemCount;
  final VoidCallback? onComplete;
  final bool isPreview;

  const MathMissionScreen({
    super.key,
    this.difficulty = MathDifficulty.easy,
    this.problemCount = 3,
    this.onComplete,
    this.isPreview = false,
  });

  @override
  State<MathMissionScreen> createState() => _MathMissionScreenState();
}

class _MathMissionScreenState extends State<MathMissionScreen> {
  late int _a, _b;
  late String _op, _problemText;
  late int _answer;
  final _ctrl = TextEditingController();
  int _solved = 0;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _nextProblem();
  }

  void _nextProblem() {
    final rng = Random();
    final diff = widget.difficulty;

    final maxVal = switch (diff) {
      MathDifficulty.easy => 10,
      MathDifficulty.medium => 25,
      MathDifficulty.hard => 50,
    };
    final ops = switch (diff) {
      MathDifficulty.easy => ['+', '-'],
      MathDifficulty.medium => ['+', '-', '×'],
      MathDifficulty.hard => ['+', '-', '×', '÷'],
    };

    if (diff == MathDifficulty.hard) {
      final opA = ops[rng.nextInt(ops.length)];
      final opB = ops[rng.nextInt(ops.length)];
      int x, y, z, mid;

      switch (opA) {
        case '+':
          x = rng.nextInt(maxVal) + 1; y = rng.nextInt(maxVal) + 1; mid = x + y;
        case '-':
          x = rng.nextInt(maxVal) + 2; y = rng.nextInt(x - 1) + 1; mid = x - y;
        case '×':
          x = rng.nextInt(maxVal ~/ 2) + 2; y = rng.nextInt(maxVal ~/ 2) + 2; mid = x * y;
        default:
          y = rng.nextInt(maxVal ~/ 2) + 2; mid = rng.nextInt(maxVal ~/ 2) + 1; x = y * mid;
      }

      switch (opB) {
        case '+':
          z = rng.nextInt(maxVal) + 1; _answer = mid + z;
        case '-':
          z = rng.nextInt(maxVal) + 1; _answer = mid - z;
        case '×':
          z = rng.nextInt(maxVal ~/ 2) + 2; _answer = mid * z;
        default:
          final absMid = mid.abs();
          if (absMid < 2) { z = 1; } else {
            final factors = [for (var i = 2; i <= absMid; i++) if (absMid % i == 0) i];
            z = factors[rng.nextInt(factors.length)];
          }
          _answer = mid ~/ z;
      }

      _a = x; _b = y; _op = opA;
      _problemText = '($x $opA $y) $opB $z = ?';
      _ctrl.clear(); _showError = false;
      return;
    }

    _op = ops[rng.nextInt(ops.length)];
    switch (_op) {
      case '+':
        _a = rng.nextInt(maxVal) + 1; _b = rng.nextInt(maxVal) + 1; _answer = _a + _b;
      case '-':
        _a = rng.nextInt(maxVal) + 1; _b = rng.nextInt(_a) + 1; _answer = _a - _b;
      case '÷':
        _b = rng.nextInt(maxVal ~/ 2) + 2; _answer = rng.nextInt(maxVal ~/ 2) + 1; _a = _b * _answer;
      default:
        _a = rng.nextInt(maxVal ~/ 2) + 2; _b = rng.nextInt(maxVal ~/ 2) + 2; _answer = _a * _b;
    }
    _problemText = '$_a $_op $_b = ?';
    _ctrl.clear(); _showError = false;
  }

  void _check() {
    final input = int.tryParse(_ctrl.text.trim());
    if (input == null) return;
    if (input == _answer) {
      HapticFeedback.lightImpact();
      if (_solved + 1 >= widget.problemCount) {
        _finish();
      } else {
        setState(() { _solved++; _nextProblem(); });
      }
    } else {
      HapticFeedback.mediumImpact();
      setState(() => _showError = true);
      _ctrl.clear();
    }
  }

  void _finish() {
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
    _ctrl.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
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
            Column(
              children: [
                const LevioBrandHeader(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.dismissMathProgress(_solved + 1, widget.problemCount),
                          style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
                        ),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: _solved / widget.problemCount,
                            minHeight: 6.h,
                            backgroundColor: c.separator,
                            valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                          ),
                        ),
                        SizedBox(height: 48.h),
                        Text(
                          _problemText,
                          style: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.bold,
                            color: c.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(height: 36.h),
                        TextField(
                          controller: _ctrl,
                          keyboardType: const TextInputType.numberWithOptions(signed: true),
                          textAlign: TextAlign.center,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: c.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: '?',
                            hintStyle: TextStyle(fontSize: 32.sp, color: c.textSecondary),
                            filled: true,
                            fillColor: c.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide.none,
                            ),
                            errorText: _showError ? l10n.dismissMathWrong : null,
                          ),
                          onSubmitted: (_) => _check(),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: _check,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 54.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.dismissMathConfirm,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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
                    decoration: BoxDecoration(color: c.card, shape: BoxShape.circle),
                    child: Icon(Icons.close, size: 18.sp, color: c.textPrimary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
