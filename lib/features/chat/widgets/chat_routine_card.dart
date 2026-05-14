import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_palette.dart';
import '../services/chat_routine_mutation.dart';

/// Compact, non-interactive confirmation card shown after Gemini created,
/// updated, or deleted a routine on the user's behalf.
class ChatRoutineCard extends StatelessWidget {
  final ChatRoutineMutation mutation;
  final VoidCallback? onTap;

  const ChatRoutineCard({super.key, required this.mutation, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tint = routineColor(mutation.colorKey);
    final icon = routineIcon(mutation.iconKey);

    final summary = _summaryFor(l10n);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: tint.withAlpha(60), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: tint.withAlpha(40),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: tint, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    mutation.routineType == RoutineType.action
                        ? l10n.routineTypeAction
                        : l10n.routineTypeHabit,
                    style: TextStyle(fontSize: 12.sp, color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _summaryFor(AppLocalizations l10n) {
    switch (mutation.kind) {
      case ChatRoutineMutationKind.created:
        return l10n.chatRoutineCreated(mutation.routineName);
      case ChatRoutineMutationKind.updated:
        return l10n.chatRoutineUpdated(mutation.routineName);
      case ChatRoutineMutationKind.deleted:
        return l10n.chatRoutineDeleted(mutation.routineName);
    }
  }
}
