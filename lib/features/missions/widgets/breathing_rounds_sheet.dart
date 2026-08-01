import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Bottom sheet to pick how many breaths a breathing session should run,
/// via a simple +/- stepper. Resolves to the chosen count, or `null` if
/// dismissed without starting.
Future<int?> showBreathingRoundsSheet(
  BuildContext context, {
  int defaultRounds = 3,
  int minRounds = 1,
  int maxRounds = 10,
}) {
  final c = AppColors.of(context);
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: c.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _BreathingRoundsSheet(
      defaultRounds: defaultRounds,
      minRounds: minRounds,
      maxRounds: maxRounds,
    ),
  );
}

class _BreathingRoundsSheet extends StatefulWidget {
  final int defaultRounds;
  final int minRounds;
  final int maxRounds;

  const _BreathingRoundsSheet({
    required this.defaultRounds,
    required this.minRounds,
    required this.maxRounds,
  });

  @override
  State<_BreathingRoundsSheet> createState() => _BreathingRoundsSheetState();
}

class _BreathingRoundsSheetState extends State<_BreathingRoundsSheet> {
  late int _rounds = widget.defaultRounds;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.breathingRoundsPickerTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            _Stepper(
              value: _rounds,
              min: widget.minRounds,
              max: widget.maxRounds,
              onChanged: (v) => setState(() => _rounds = v),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: withMediumHaptic(
                    () => Navigator.of(context).pop(_rounds)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.textPrimary,
                  foregroundColor: c.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
                  l10n.breathingRoundsPickerStart,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple +/- stepper widget.
class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepButton(
          icon: Icons.remove,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
          c: c,
        ),
        SizedBox(width: 32.w),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
            color: c.textPrimary,
          ),
        ),
        SizedBox(width: 32.w),
        _stepButton(
          icon: Icons.add,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
          c: c,
        ),
      ],
    );
  }

  Widget _stepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required AppColors c,
  }) {
    return GestureDetector(
      onTap: enabled ? withHaptic(onTap) : null,
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: enabled ? c.textPrimary : c.separator,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? c.background : c.textSecondary,
          size: 24.sp,
        ),
      ),
    );
  }
}
