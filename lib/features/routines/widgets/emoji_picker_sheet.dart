import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/routine_palette.dart';

/// Modal bottom sheet grid for picking a routine emoji. Returns the chosen
/// emoji via `Navigator.pop`.
Future<String?> showEmojiPickerSheet(
  BuildContext context, {
  required String selectedEmoji,
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
              AppLocalizations.of(context)!.routineFormEmojiLabel,
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
              children: kRoutineEmojis.map((emoji) {
                final selected = emoji == selectedEmoji;
                return GestureDetector(
                  onTap: withHaptic(() => Navigator.pop(ctx, emoji)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? tint.withAlpha(50) : c.background,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: tint, width: 2)
                          : null,
                    ),
                    child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
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
