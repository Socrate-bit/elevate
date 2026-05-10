import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Generic placeholder survey step. Replace [question] / [options] per project.
class SurveyStep extends StatelessWidget {
  final String question;
  final String questionKey;
  final List<String> options;

  const SurveyStep({
    super.key,
    required this.question,
    required this.questionKey,
    this.options = const ['Option A', 'Option B', 'Option C'],
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final selected = state.surveyAnswers[questionKey];
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Text(
                question,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 24.h),
              ...options.map((option) {
                final isSelected = selected == option;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: GestureDetector(
                    onTap: withHaptic(() => context
                        .read<OnboardingCubit>()
                        .answerSurvey(questionKey, option)),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isSelected ? c.primary : c.separator,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? c.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? c.primary
                                    : c.textSecondary,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(Icons.check,
                                    size: 16.sp, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
