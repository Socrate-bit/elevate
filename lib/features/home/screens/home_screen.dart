import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';
import '../../../shared/utils/haptic_utils.dart';

import '../../mood/cubit/mood_cubit.dart';
import '../../mood/cubit/mood_state.dart';
import '../../mood/models/mood_entry.dart';
import '../../mood/widgets/mood_picker_sheet.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/bottom_nav_shell.dart';
import '../../missions/screens/photo_mission_screen.dart';
import '../../missions/models/mission.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../../routines/cubit/routine_state.dart';
import '../../routines/models/routine.dart';
import '../../routines/screens/routine_form_screen.dart';
import '../../routines/widgets/action_card.dart';
import '../../routines/widgets/habit_card.dart';
import '../../activity/models/activity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) =>
          HomeCubit(routineCubit: context.read<RoutineCubit>())..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            bottom: false,
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        _TopBar(streak: state.currentStreak),
                        SizedBox(height: 20.h),
                        BlocBuilder<MoodCubit, MoodState>(
                          builder: (context, moodState) => _WeekRow(
                            weekDays: state.weekDays,
                            weekMoods: moodState.weekMoods,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        BlocBuilder<RoutineCubit, RoutineState>(
                          builder: (context, routineState) {
                            return _RoutineSections(
                              routines: routineState.routines,
                              completedActivities: state.completedActivities,
                            );
                          },
                        ),
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _RoutineSections extends StatelessWidget {
  final List<Routine> routines;
  final List<Activity> completedActivities;

  const _RoutineSections({
    required this.routines,
    required this.completedActivities,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final actions = routines
        .where((r) => r.type == RoutineType.action)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final habits = routines
        .where((r) => r.type == RoutineType.habit)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final today = DateTime.now();
    final completedTodayIds = completedActivities
        .where((a) => a.completed && _isSameDay(a.timestamp, today))
        .map((a) => a.sourceId)
        .whereType<String>()
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeActionsTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: c.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        if (actions.isEmpty)
          _EmptySection(text: l10n.homeActionsEmpty)
        else
          ...actions.map(
            (r) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: ActionCard(
                routine: r,
                onValidate: () => _validate(context, r),
                onEdit: () => _edit(context, r),
              ),
            ),
          ),
        SizedBox(height: 24.h),
        Text(
          l10n.homeHabitsTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: c.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        if (habits.isEmpty)
          _EmptySection(text: l10n.homeHabitsEmpty)
        else
          ...habits.map(
            (r) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: HabitCard(
                routine: r,
                completedToday: completedTodayIds.contains(r.id),
                scheduledToday: r.isScheduledToday,
                onValidate: () => _validate(context, r),
                onEdit: () => _edit(context, r),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _validate(BuildContext context, Routine r) async {
    final cubit = context.read<RoutineCubit>();
    final objectCheck = r.objectCheck;
    if (objectCheck == null || objectCheck.isEmpty) {
      await cubit.validate(r.id);
      return;
    }
    final nav = Navigator.of(context);
    await nav.push(
      MaterialPageRoute(
        builder: (_) => PhotoMissionScreen(
          missionType: MissionType.objectHunt,
          selectedItems: [objectCheck],
          onComplete: () async {
            nav.pop();
            await cubit.validate(r.id);
          },
        ),
      ),
    );
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _EmptySection extends StatelessWidget {
  final String text;
  const _EmptySection({required this.text});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int streak;
  const _TopBar({required this.streak});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(
          l10n.appTitle,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: c.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: withHaptic(() => BottomNavShell.of(context)?.navigateTo(1)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 18.sp, color: c.primary),
                SizedBox(width: 4.w),
                Text(
                  '$streak',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: withHaptic(() => showMoodPickerSheet(context)),
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: c.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8),
              ],
            ),
            child: Center(
              child: Text('🙂', style: TextStyle(fontSize: 18.sp)),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final List<DayStatus> weekDays;
  final Map<int, MoodValue> weekMoods;

  const _WeekRow({required this.weekDays, required this.weekMoods});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final todayIndex = now.weekday % 7; // 0=Sun

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final isToday = i == todayIndex;
        final isFuture = i > todayIndex;
        final status = weekDays.length > i ? weekDays[i] : DayStatus.none;
        final label = localizedDayShort(l10n, i);
        final mood = weekMoods[i];

        // Content inside the circle: mood emoji or faded dash
        Widget circleContent;
        if (mood != null) {
          circleContent = Text(mood.emoji, style: TextStyle(fontSize: 18.sp));
        } else {
          circleContent = Text(
            '—',
            style: TextStyle(
              fontSize: 14.sp,
              color: c.textSecondary.withAlpha(80),
            ),
          );
        }

        if (isToday) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 42.w,
                  height: 42.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: status == DayStatus.done
                        ? Border.all(color: c.primary, width: 2)
                        : Border.all(color: c.separator, width: 2),
                  ),
                  child: Center(child: circleContent),
                ),
              ],
            ),
          );
        }

        Widget circle;
        if (status == DayStatus.done) {
          circle = Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.primary, width: 2),
            ),
            child: Center(child: circleContent),
          );
        } else if (status == DayStatus.frozen) {
          circle = Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.frozen, width: 2.5),
            ),
            child: Center(child: circleContent),
          );
        } else if (isFuture) {
          circle = Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: c.textSecondary.withAlpha(50), width: 2.5),
            ),
            child: Center(
              child: Text(
                '—',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: c.textSecondary.withAlpha(40),
                ),
              ),
            ),
          );
        } else {
          circle = CustomPaint(
            painter: _DashedCirclePainter(
              color: c.textSecondary.withAlpha(120),
              strokeWidth: 2.5,
              dashLength: 4,
              gapLength: 3,
            ),
            child: SizedBox(
              width: 42.w,
              height: 42.h,
              child: Center(child: circleContent),
            ),
          );
        }

        return Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: c.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            circle,
          ],
        );
      }),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * 3.14159265 * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();
    final dashAngle = (dashLength / circumference) * 2 * 3.14159265;
    final totalAngle = 2 * 3.14159265 / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * totalAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth;
}
