import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_helpers.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/mood_cubit.dart';
import '../cubit/mood_state.dart';
import '../models/mood_entry.dart';

/// Opens a full-screen-style bottom sheet for picking a mood.
void showMoodPickerSheet(BuildContext context) {
  final cubit = context.read<MoodCubit>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _MoodPickerSheet(),
    ),
  );
}

class _MoodPickerSheet extends StatelessWidget {
  const _MoodPickerSheet();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final isPM = hour >= 12;
    final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final dateStr =
        '${localizedDayFull(l10n, now.weekday % 7)}, ${now.day} ${localizedMonth(l10n, now.month)} at $h12:$minute ${isPM ? 'PM' : 'AM'}';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Drag handle
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: c.separator,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),
            // Header row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: withHaptic(() => Navigator.of(context).pop()),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: c.separator,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Title
            Text(
              l10n.moodPickerTitle,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 6.h),
            // Date/time subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13.sp,
                  color: AppColors.brand,
                ),
                SizedBox(width: 4.w),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.brand,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 36.h),
            // Mood icons row
            BlocBuilder<MoodCubit, MoodState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: MoodValue.values.map((mood) {
                      return GestureDetector(
                        onTap: state.isSaving
                            ? null
                            : withHaptic(() async {
                                await context
                                    .read<MoodCubit>()
                                    .saveMood(mood, source: 'modal');
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }),
                        child: Column(
                          children: [
                            Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                color: mood.color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  mood.emoji,
                                  style: TextStyle(fontSize: 28.sp),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _moodLabel(l10n, mood),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: c.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _moodLabel(AppLocalizations l10n, MoodValue mood) => switch (mood) {
        MoodValue.rad => l10n.moodPickerRad,
        MoodValue.good => l10n.moodPickerGood,
        MoodValue.meh => l10n.moodPickerMeh,
        MoodValue.bad => l10n.moodPickerBad,
        MoodValue.awful => l10n.moodPickerAwful,
      };
}

