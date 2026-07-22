import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/mood_entry.dart';

/// Community-style mood face: an illustrated PNG on a soft pastel rounded-square
/// tile, with an optional label below. Scales up when [selected] and dims when
/// [dimmed] (used to fade the non-chosen faces once a mood is picked).
class MoodFace extends StatelessWidget {
  final MoodValue mood;

  /// Label shown under the face; hidden when null.
  final String? label;
  final bool selected;
  final bool dimmed;

  /// Tile side length (the face image is 75% of this).
  final double size;
  final VoidCallback? onTap;

  const MoodFace({
    super.key,
    required this.mood,
    this.label,
    this.selected = false,
    this.dimmed = false,
    this.size = 56,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final face = AnimatedScale(
      scale: selected ? 1.12 : 1,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: size.w,
        height: size.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mood.tileColor,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Image.asset(
          mood.asset,
          width: (size * 0.75).w,
          height: (size * 0.75).w,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap == null ? null : withHaptic(onTap!),
      child: Opacity(
        opacity: dimmed ? 0.3 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            face,
            if (label != null) ...[
              SizedBox(height: 4.h),
              SizedBox(
                width: (size - 4).w,
                child: Text(
                  label!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? c.textPrimary : c.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
