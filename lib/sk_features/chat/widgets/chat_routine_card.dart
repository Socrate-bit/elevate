import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_palette.dart';
import '../services/chat_routine_mutation.dart';

/// Compact confirmation card shown after Gemini created, updated, or deleted
/// a routine. For actions created and scheduled today, shows a "Start now"
/// button that validates the action and triggers [onStartNow].
class ChatRoutineCard extends StatefulWidget {
  final ChatRoutineMutation mutation;

  /// Called when user taps "Start now" on a today-scheduled created action.
  final VoidCallback? onStartNow;

  const ChatRoutineCard({super.key, required this.mutation, this.onStartNow});

  @override
  State<ChatRoutineCard> createState() => _ChatRoutineCardState();
}

class _ChatRoutineCardState extends State<ChatRoutineCard> {
  bool _completed = false;

  bool get _showStartNow =>
      !_completed &&
      widget.onStartNow != null &&
      widget.mutation.kind == ChatRoutineMutationKind.created &&
      widget.mutation.routineType == RoutineType.action &&
      widget.mutation.isScheduledToday;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tint = routineColor(widget.mutation.colorKey);
    final icon = routineIcon(widget.mutation.iconKey);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        widget.mutation.routineType == RoutineType.action
                            ? l10n.routineTypeAction
                            : l10n.routineTypeHabit,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showStartNow) ...[
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: withMediumHaptic(() {
                  setState(() => _completed = true);
                  widget.onStartNow?.call();
                }),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.chatActionStartNow,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else if (_completed) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14.sp,
                    color: c.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    l10n.chatActionDone,
                    style: TextStyle(fontSize: 12.sp, color: c.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _summaryFor(AppLocalizations l10n) {
    switch (widget.mutation.kind) {
      case ChatRoutineMutationKind.created:
        return l10n.chatRoutineCreated(widget.mutation.routineName);
      case ChatRoutineMutationKind.updated:
        return l10n.chatRoutineUpdated(widget.mutation.routineName);
      case ChatRoutineMutationKind.deleted:
        return l10n.chatRoutineDeleted(widget.mutation.routineName);
    }
  }
}
