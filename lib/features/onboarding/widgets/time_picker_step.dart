import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Generic time picker step. Stores `HH:MM` in onboarding survey answers
/// under [answerKey].
class TimePickerStep extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String answerKey;
  final TimeOfDay initialTime;

  const TimePickerStep({
    super.key,
    required this.title,
    required this.answerKey,
    this.subtitle,
    this.initialTime = const TimeOfDay(hour: 7, minute: 0),
  });

  @override
  State<TimePickerStep> createState() => _TimePickerStepState();
}

class _TimePickerStepState extends State<TimePickerStep> {
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _time = _parseExistingAnswer() ?? widget.initialTime;
    _hourController = FixedExtentScrollController(initialItem: _time.hour);
    _minuteController = FixedExtentScrollController(initialItem: _time.minute);
    // Ensure the cubit has the initial value even if the user doesn't scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) => _persist(_time));
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay? _parseExistingAnswer() {
    final raw =
        context.read<OnboardingCubit>().state.surveyAnswers[widget.answerKey];
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  void _persist(TimeOfDay t) {
    final s = '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
    context.read<OnboardingCubit>().answerSurvey(widget.answerKey, s);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (_, __) => false,
      builder: (context, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
                height: 1.2,
              ),
            ),
            if (widget.subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                widget.subtitle!,
                style: TextStyle(fontSize: 16.sp, color: c.textSecondary),
              ),
            ],
            const Spacer(),
            Center(
              child: Text(
                _formatTime(_time),
                style: TextStyle(
                  fontSize: 64.sp,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 200.h,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _hourController,
                      itemExtent: 40.h,
                      onSelectedItemChanged: (i) {
                        final next = TimeOfDay(hour: i, minute: _time.minute);
                        setState(() => _time = next);
                        _persist(next);
                      },
                      children: List.generate(
                        24,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: TextStyle(
                                fontSize: 22.sp, color: c.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _minuteController,
                      itemExtent: 40.h,
                      onSelectedItemChanged: (i) {
                        final next = TimeOfDay(hour: _time.hour, minute: i);
                        setState(() => _time = next);
                        _persist(next);
                      },
                      children: List.generate(
                        60,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: TextStyle(
                                fontSize: 22.sp, color: c.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
