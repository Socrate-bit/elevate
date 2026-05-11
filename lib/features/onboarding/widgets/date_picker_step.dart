import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Generic date picker step. Stores ISO `YYYY-MM-DD` in onboarding survey
/// answers under [answerKey].
class DatePickerStep extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String answerKey;
  final DateTime? initialDate;

  const DatePickerStep({
    super.key,
    required this.title,
    required this.answerKey,
    this.subtitle,
    this.initialDate,
  });

  @override
  State<DatePickerStep> createState() => _DatePickerStepState();
}

class _DatePickerStepState extends State<DatePickerStep> {
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = _parseExistingAnswer() ?? widget.initialDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _persist(_date));
  }

  DateTime? _parseExistingAnswer() {
    final raw =
        context.read<OnboardingCubit>().state.surveyAnswers[widget.answerKey];
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  void _persist(DateTime d) {
    final iso = '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    context.read<OnboardingCubit>().answerSurvey(widget.answerKey, iso);
  }

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
            Expanded(
              flex: 4,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _date,
                maximumDate: DateTime.now(),
                minimumYear: 1900,
                maximumYear: DateTime.now().year,
                onDateTimeChanged: (d) {
                  setState(() => _date = d);
                  _persist(d);
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
