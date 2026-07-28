import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// A dimension to rate: a stable [key] (stored) and a localized [label].
class LifeDimension {
  final String key;
  final String label;
  const LifeDimension(this.key, this.label);
}

/// Lets the user rate several life dimensions on a 1–5 scale.
class LifeRatingStep extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<LifeDimension> dimensions;
  final Map<String, int> ratings;
  final void Function(String key, int value) onRate;

  const LifeRatingStep({
    super.key,
    required this.title,
    required this.dimensions,
    required this.ratings,
    required this.onRate,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SingleChildScrollView(
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
          SizedBox(height: 24.h),
          ...dimensions.map((dim) {
            final value = ratings[dim.key] ?? 0;
            return Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dim.label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      for (var i = 1; i <= 5; i++) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: withHaptic(() => onRate(dim.key, i)),
                            child: Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: i <= value ? c.primary : c.card,
                                border: Border.all(
                                  color: i <= value ? c.primary : c.separator,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$i',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: i <= value
                                      ? Colors.white
                                      : c.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (i < 5) SizedBox(width: 8.w),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
