import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/routine_palette.dart';

/// Modal bottom sheet grid for picking a routine icon. Returns the chosen
/// icon key via `Navigator.pop`.
Future<String?> showIconPickerSheet(
  BuildContext context, {
  required String selectedKey,
  required Color tint,
}) {
  final c = AppColors.of(context);
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: c.card,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.routineFormIconLabel,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 6,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              children: kRoutineIcons.entries.map((entry) {
                final selected = entry.key == selectedKey;
                return GestureDetector(
                  onTap: withHaptic(() => Navigator.pop(ctx, entry.key)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: selected ? tint : c.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      entry.value,
                      color: selected ? Colors.white : c.textPrimary,
                      size: 22.sp,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}
