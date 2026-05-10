import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';

class InfoStep extends StatelessWidget {
  final String title;
  final String? body;

  const InfoStep({super.key, required this.title, this.body});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
              height: 1.2,
            ),
          ),
          if (body != null) ...[
            SizedBox(height: 16.h),
            Text(
              body!,
              style: TextStyle(
                fontSize: 16.sp,
                color: c.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}
