import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../adventure/cubit/adventure_cubit.dart';
import '../../chat/screens/chat_page_screen.dart';
import '../../missions/screens/breathing_intro_screen.dart';
import '../../mood/widgets/mood_picker_sheet.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/routine_palette.dart';
import '../../routines/screens/routine_form_screen.dart';
import '../../tools/models/tools_mock_data.dart';
import '../../tools/tools_launcher.dart';
import '../models/default_task.dart';
import 'home_action_sheet.dart';

/// Today's plan on the green background, split into two sections: the fixed
/// inner-work "Routine" (mood / breathing / introspection rituals) and the
/// user-added "Quests" (their own routines and activities). Each section has a
/// header and its own white cards.
class TodaysPlanCard extends StatelessWidget {
  final List<Routine> routines;
  final Set<String> completedIds;

  const TodaysPlanCard({
    super.key,
    required this.routines,
    required this.completedIds,
  });

  @override
  Widget build(BuildContext context) {
    // Unchecked items first within each list (done items sink to the bottom),
    // keeping their original order within each group.
    final sortedDefaults = [
      ...kDefaultTasks.where((t) => !completedIds.contains(t.id)),
      ...kDefaultTasks.where((t) => completedIds.contains(t.id)),
    ];
    final sortedRoutines = [
      ...routines.where((r) => !completedIds.contains(r.id)),
      ...routines.where((r) => completedIds.contains(r.id)),
    ];
    // Once every routine ritual is done, surface the Quests section first.
    final routineDone =
        kDefaultTasks.every((t) => completedIds.contains(t.id));

    final routineSection = _routineSection(context, sortedDefaults);
    final questsSection = _questsSection(context, sortedRoutines);

    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 90.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: routineDone
            ? [...questsSection, SizedBox(height: 24.h), ...routineSection]
            : [...routineSection, SizedBox(height: 24.h), ...questsSection],
      ),
    );
  }

  /// Inner-work Routine: the fixed daily rituals (not addable). They stay
  /// visible once done — locked in a completed state, not hidden.
  List<Widget> _routineSection(BuildContext context, List<DefaultTask> tasks) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _SectionHeader(
        icon: Icons.self_improvement_rounded,
        title: l10n.homePageRoutineSection,
        subtitle: l10n.homePageRoutineSubtitle,
      ),
      SizedBox(height: 14.h),
      ...tasks.map(
        (t) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _DefaultTaskCard(
            task: t,
            done: completedIds.contains(t.id),
            onTap: () => _startDefaultTask(context, t),
          ),
        ),
      ),
    ];
  }

  /// Quests: the tasks / activities the user added themselves.
  List<Widget> _questsSection(BuildContext context, List<Routine> items) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _SectionHeader(
        icon: Icons.flag_rounded,
        title: l10n.homePageQuestsSection,
        subtitle: l10n.homePageQuestsSubtitle,
        // Add a task / activity to the quests.
        trailing: _AddButton(onTap: () => showHomeAddSheet(context)),
      ),
      SizedBox(height: 14.h),
      if (items.isEmpty)
        _EmptyPlan(text: l10n.homePageQuestsEmpty)
      else
        ...items.map(
          (r) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _TaskCard(
              routine: r,
              done: completedIds.contains(r.id),
              onToggle: () => _toggle(context, r, completedIds.contains(r.id)),
              onEdit: () => _edit(context, r),
            ),
          ),
        ),
    ];
  }

  /// Validates or un-validates the routine for today.
  Future<void> _toggle(BuildContext context, Routine r, bool done) async {
    final cubit = context.read<RoutineCubit>();
    final adventure = context.read<AdventureCubit>();
    if (done) {
      await cubit.unvalidate(r.id);
      // Un-checking reverses the coins + strike it granted.
      await adventure.removeForCompletion(r.xp);
      return;
    }
    await cubit.validate(r.id);
    // Award coins (== the task's XP) + a strike; fires confetti on home.
    await adventure.awardForCompletion(r.xp);
  }

  void _edit(BuildContext context, Routine r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RoutineCubit>(),
          child: RoutineFormScreen(routine: r),
        ),
      ),
    );
  }

  /// Runs a default task's underlying feature; each marks itself done on
  /// success (mood recorded, breathing finished, or a first chat message sent).
  Future<void> _startDefaultTask(BuildContext context, DefaultTask task) async {
    final adventure = context.read<AdventureCubit>();
    switch (task.kind) {
      case DefaultTaskKind.mood:
        final saved = await showMoodPickerSheet(context);
        if (saved != null) {
          await DefaultTaskCompletion.complete(task: task, adventure: adventure);
        }
      case DefaultTaskKind.breathing:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BreathingIntroScreen(
              // Mark the task complete; the breathing screen itself navigates
              // to the completion screen once the animation finishes.
              onComplete: () =>
                  DefaultTaskCompletion.complete(task: task, adventure: adventure),
            ),
          ),
        );
      case DefaultTaskKind.introspection:
        // Restart the intro workflow: open chat with the 3-option starter card
        // shown, even on the ongoing conversation. Completion is recorded by
        // ChatCubit when the first message is sent.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ChatPage(fullScreen: true, forceStarter: true),
          ),
        );
    }
  }
}

/// A plan section header (white over green): icon, title + subtitle, and an
/// optional trailing action (e.g. the add button on the Quests section).
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Round white "+" button in the plan header — opens the add-task sheet.
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        width: 34.w,
        height: 34.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 24.sp),
      ),
    );
  }
}

/// Empty-state shown when nothing is planned for today — plain white writing
/// over the green background (no card).
class _EmptyPlan extends StatelessWidget {
  final String text;
  const _EmptyPlan({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// A built-in daily prompt as a white card. Same look as a routine card, but
/// the whole card is tappable to start its feature; completion is driven by
/// that feature (not a manual check), so it shows a "start" affordance.
class _DefaultTaskCard extends StatelessWidget {
  final DefaultTask task;
  final bool done;
  final VoidCallback onTap;

  const _DefaultTaskCard({
    required this.task,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tile = routineColor(task.colorKey);
    return GestureDetector(
      // Locked once completed today — can be started, but not un-done.
      onTap: done ? null : withHaptic(onTap),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: HomePalette.cardWhite,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular emoji tile, tinted by the task's color.
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tile.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Text(task.emoji, style: TextStyle(fontSize: 22.sp)),
            ),
            SizedBox(width: 12.w),
            // Title + subtitle.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    defaultTaskName(l10n, task.kind),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: HomePalette.titleDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    defaultTaskSubtitle(l10n, task.kind),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: HomePalette.subtitleGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // XP reward: number + seedling.
            Text(
              '${task.xp}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.titleDark,
              ),
            ),
            SizedBox(width: 6.w),
            Image.asset('assets/home_page/plant.png', width: 22.w),
            SizedBox(width: 10.w),
            // Done: a locked green check. Otherwise a "start" affordance
            // (the whole card handles the tap).
            done
                ? Container(
                    width: 40.w,
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 14, 165, 19),
                      borderRadius: BorderRadius.circular(90.r),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 28.sp,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    width: 40.w,
                    height: 40.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tile.withAlpha(40),
                      borderRadius: BorderRadius.circular(90.r),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 26.sp,
                      color: tile,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// One routine as a white card: emoji tile, title + subtitle, XP and check.
class _TaskCard extends StatelessWidget {
  final Routine routine;
  final bool done;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _TaskCard({
    required this.routine,
    required this.done,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tile = routineColor(routine.colorKey);
    // Activity/tool task: resolve its tool so we can show its asset icon and
    // open its guided session on tap (falling back to edit when there's none).
    final tool =
        routine.toolKey == null ? null : ToolsMockData.byKey(routine.toolKey!);
    final opensSession = tool != null && tool.hasSession;
    return GestureDetector(
      onTap: withHaptic(
        opensSession ? () => openToolSession(context, tool) : onEdit,
      ),
      // Keep tool tasks manageable (edit/delete) via long-press.
      onLongPress: opensSession ? withHaptic(onEdit) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: HomePalette.cardWhite,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular tile: the tool's asset icon, or the routine's emoji.
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tile.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: tool != null
                  ? Image.asset(tool.iconAsset, width: 26.w, height: 26.w)
                  : Text(routine.emoji, style: TextStyle(fontSize: 22.sp)),
            ),
            SizedBox(width: 12.w),
            // Title + subtitle.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: HomePalette.titleDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    tool?.subtitle ?? _subtitle(l10n),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: HomePalette.subtitleGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // XP reward: number + seedling.
            Text(
              '${routine.xp}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.titleDark,
              ),
            ),
            SizedBox(width: 6.w),
            Image.asset('assets/home_page/plant.png', width: 22.w),
            SizedBox(width: 10.w),
            _CheckButton(
              done: done,
              hasObjectCheck: routine.objectCheck != null,
              onTap: onToggle,
            ),
          ],
        ),
      ),
    );
  }

  /// Description if set, otherwise a compact schedule / hint string.
  String _subtitle(AppLocalizations l10n) {
    final desc = routine.description;
    if (desc != null && desc.trim().isNotEmpty) return desc.trim();

    if (routine.objectCheck != null && routine.objectCheck!.isNotEmpty) {
      return l10n.routineCardObjectCheck(routine.objectCheck!);
    }

    final time = routine.scheduledMinute;
    final timeStr = time == null
        ? null
        : '${(time ~/ 60).toString().padLeft(2, '0')}:'
              '${(time % 60).toString().padLeft(2, '0')}';

    if (routine.type == RoutineType.habit) {
      final days = _daysLabel(l10n);
      return timeStr == null ? days : '$days · $timeStr';
    }
    return timeStr ?? l10n.routineCardTapToValidate;
  }

  String _daysLabel(AppLocalizations l10n) {
    final days = routine.scheduledDays;
    if (days.every((d) => d)) return l10n.alarmsEveryDay;
    if (days.every((d) => !d)) return l10n.routineHabitNoSchedule;
    if (days.length == 7 &&
        days[1] &&
        days[2] &&
        days[3] &&
        days[4] &&
        days[5] &&
        !days[0] &&
        !days[6]) {
      return l10n.alarmsWeekdays;
    }
    final selected = <String>[];
    for (var i = 0; i < days.length; i++) {
      if (days[i]) selected.add(localizedDayShort(l10n, i));
    }
    return selected.join(', ');
  }
}

/// Tappable check button: grey rounded square; green check when done.
class _CheckButton extends StatelessWidget {
  final bool done;
  final bool hasObjectCheck;
  final VoidCallback onTap;

  const _CheckButton({
    required this.done,
    required this.hasObjectCheck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withMediumHaptic(onTap),
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: done ? const Color.fromARGB(255, 14, 165, 19) : HomePalette.checkButtonBg,
          borderRadius: BorderRadius.circular(90.r),
          border: Border.all(
            color: done ? const Color.fromARGB(255, 14, 165, 19) : HomePalette.checkButtonBorder,
            width: 1,
          ),
        ),
        child: Icon(
          done
              ? Icons.check_rounded
              : (hasObjectCheck
                    ? Icons.camera_alt_rounded
                    : Icons.check_rounded),
          size: 28.sp,
          color: done ? Colors.white : HomePalette.checkButtonBorder,
        ),
      ),
    );
  }
}
