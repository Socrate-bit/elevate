import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';

class DatePickerStep extends StatelessWidget {
  final String title;
  final String? subtitle;
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  const DatePickerStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.date,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 16.sp, color: c.textSecondary),
            ),
          ],
          const Spacer(),
          Expanded(
            flex: 4,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: date,
              maximumDate: DateTime.now(),
              minimumYear: 1900,
              maximumYear: DateTime.now().year,
              onDateTimeChanged: onDateChanged,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
