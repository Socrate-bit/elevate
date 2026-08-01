import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';

/// Centered motivational / educational page: an optional illustration (widget)
/// or emoji, a headline, an optional body, and an optional footnote (rendered
/// with a small lock icon, e.g. a privacy reassurance). The primary CTA is the
/// shared Continue button owned by the flow screen, whose label is set per-page.
class EducationStep extends StatelessWidget {
  final String title;
  final String? body;
  final String? emoji;
  final String? footnote;

  /// Optional illustration shown above the title, in place of [emoji]
  /// (e.g. the Appy mascot). Takes precedence over [emoji] when both are set.
  final Widget? illustration;

  const EducationStep({
    super.key,
    required this.title,
    this.body,
    this.emoji,
    this.footnote,
    this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (illustration != null) ...[
                  illustration!,
                  SizedBox(height: 24.h),
                ] else if (emoji != null) ...[
                  Text(emoji!, style: TextStyle(fontSize: 72.sp)),
                  SizedBox(height: 24.h),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),
                if (body != null) ...[
                  SizedBox(height: 18.h),
                  Text(
                    body!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: c.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                if (footnote != null) ...[
                  SizedBox(height: 28.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 16.sp, color: c.textSecondary),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          footnote!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
