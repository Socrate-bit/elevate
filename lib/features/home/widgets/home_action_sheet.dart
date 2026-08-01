import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../adventure/cubit/adventure_cubit.dart';
import '../../missions/screens/breathing_mission_screen.dart';
import '../../missions/widgets/breathing_rounds_sheet.dart';
import '../../mood/widgets/mood_picker_sheet.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../routines/models/routine.dart';
import '../../routines/screens/routine_form_screen.dart';
import '../../tools/models/tools_mock_data.dart';
import '../../tools/widgets/tool_card.dart';
import '../models/default_task.dart';

/// Emoji stored on a tool-task routine. It's a fallback — the plan card shows
/// the tool's asset icon (resolved from `toolKey`), not this emoji.
const _kToolTaskEmoji = '🌿';

/// Routine color for tool-task routines (matches the wellness accent).
const _kToolTaskColorKey = 'green';

/// Themed "add to your day" sheet opened from the home plan's "+" button.
/// Top: the classic quick-add options (Action, Habit, Mood, Breathing). Below:
/// the activity/tools selector — tapping an activity adds it to today's plan as
/// a task that opens its guided session when tapped later.
Future<void> showHomeAddSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final routineCubit = context.read<RoutineCubit>();
  final adventure = context.read<AdventureCubit>();
  final navigator = Navigator.of(context);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: HomePalette.cream,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (ctx) {
      // Adds an activity to today's plan; tapping the task later opens its
      // guided session (via the routine's toolKey).
      Future<void> addTool(ToolItem item) async {
        Navigator.pop(ctx);
        try {
          await routineCubit.addRoutine(Routine(
            id: '',
            type: RoutineType.action,
            name: item.title,
            emoji: _kToolTaskEmoji,
            colorKey: _kToolTaskColorKey,
            toolKey: item.key,
          ));
        } catch (_) {
          // RoutineCubit already logs + rolls back the optimistic insert.
        }
      }

      void openForm(RoutineType type) {
        Navigator.pop(ctx);
        navigator.push(MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: routineCubit,
            child: RoutineFormScreen(initialType: type),
          ),
        ));
      }

      Future<void> openMood() async {
        Navigator.pop(ctx);
        final saved = await showMoodPickerSheet(navigator.context);
        if (saved != null) {
          await DefaultTaskCompletion.complete(
            task: kMoodTask,
            adventure: adventure,
          );
        }
      }

      Future<void> openBreathing() async {
        Navigator.pop(ctx);
        // Let the user pick how many breaths before starting (default 3).
        final rounds = await showBreathingRoundsSheet(navigator.context);
        if (rounds == null) return;
        navigator.push(MaterialPageRoute(
          builder: (_) => BreathingMissionScreen(
            rounds: rounds,
            // Mark the task complete; the breathing screen itself navigates
            // to the completion screen once the animation finishes.
            onComplete: () => DefaultTaskCompletion.complete(
              task: kBreathingTask,
              adventure: adventure,
            ),
          ),
        ));
      }

      final activities = ToolsMockData.allItems;

      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grab handle.
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: HomePalette.subtitleGrey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.homeAddTitle,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.textDarkGreen,
                  ),
                ),
                SizedBox(height: 14.h),
                // Quick-add options: Action | Habit.
                Row(
                  children: [
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.bolt_rounded,
                        label: l10n.routineTypeAction,
                        description: l10n.routineTypeActionDesc,
                        onTap: () => openForm(RoutineType.action),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.repeat_rounded,
                        label: l10n.routineTypeHabit,
                        description: l10n.routineTypeHabitDesc,
                        onTap: () => openForm(RoutineType.habit),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Mood | Breathing.
                Row(
                  children: [
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.mood_rounded,
                        label: l10n.moodSectionTitle,
                        description: l10n.homeAddMoodDesc,
                        onTap: openMood,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _QuickTile(
                        icon: Icons.air_rounded,
                        label: l10n.homeAddBreathingTitle,
                        description: l10n.homeAddBreathingDesc,
                        onTap: openBreathing,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22.h),
                // Activities selector — adds the tapped tool to today's plan.
                Text(
                  l10n.homeAddActivitiesTitle,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.toolsWellnessGreen,
                  ),
                ),
                SizedBox(height: 12.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: activities.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.86,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                  ),
                  itemBuilder: (context, i) => ToolCard(
                    item: activities[i],
                    onTap: () => addTool(activities[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// A quick-add option tile: tinted icon square + label + description.
class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: HomePalette.cardWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HomePalette.toolsWellnessGreen.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: HomePalette.toolsWellnessGreen,
                size: 20.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.titleDark,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                color: HomePalette.subtitleGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
