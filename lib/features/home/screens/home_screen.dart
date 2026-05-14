import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';
import '../../../shared/utils/haptic_utils.dart';

import '../../chat/cubit/chat_cubit.dart';
import '../../chat/cubit/chat_list_cubit.dart';
import '../../chat/screens/chat_screen.dart';
import '../../mood/cubit/mood_cubit.dart';
import '../../mood/cubit/mood_state.dart';
import '../../mood/models/mood_entry.dart';
import '../../../shared/theme/app_theme.dart';
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
                        const _StartChatCard(),
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

/// Tappable card that creates a new conversation and opens ChatScreen.
class _StartChatCard extends StatefulWidget {
  const _StartChatCard();

  @override
  State<_StartChatCard> createState() => _StartChatCardState();
}

class _StartChatCardState extends State<_StartChatCard> {
  bool _loading = false;

  Future<void> _startChat() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final conv = await context.read<ChatListCubit>().createConversation();
      if (!mounted) return;
      setState(() => _loading = false);
      final routineCubit = context.read<RoutineCubit>();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ChatCubit(
              conversationId: conv.id,
              routineCubit: routineCubit,
            ),
            child: BlocProvider.value(
              value: routineCubit,
              child: ChatScreen(onNewChat: _replaceWithNewChat),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[HomeScreen] startChat failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _replaceWithNewChat() async {
    Navigator.of(context).pop();
    await _startChat();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: withHaptic(_loading ? null : _startChat),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: c.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: c.primary.withAlpha(90),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withAlpha(220),
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                l10n.chatModelName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 30.h,
              child: _loading
                  ? Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(45),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        l10n.chatStartChat,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
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
                completedToday: completedTodayIds.contains(r.id),
                onValidate: () => _validate(context, r),
                onUnvalidate: () => _unvalidate(context, r),
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
                onUnvalidate: () => _unvalidate(context, r),
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

  Future<void> _unvalidate(BuildContext context, Routine r) async {
    await context.read<RoutineCubit>().unvalidate(r.id);
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
        Container(
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
