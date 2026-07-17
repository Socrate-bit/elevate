import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';

/// Onboarding step where the user picks their public community username.
class UsernameStep extends StatelessWidget {
  const UsernameStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (p, cur) => p.username != cur.username,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Text(
                l10n.onboardingUsernameTitle,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: c.textPrimary,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.onboardingUsernameSubtitle,
                style: TextStyle(fontSize: 16.sp, color: c.textSecondary),
              ),
              const Spacer(),
              TextField(
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                onChanged: (v) =>
                    context.read<OnboardingCubit>().setUsername(v),
                decoration: InputDecoration(
                  hintText: l10n.onboardingUsernameLabel,
                  hintStyle: TextStyle(color: c.textSecondary),
                  filled: true,
                  fillColor: c.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: c.separator),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: c.separator),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
