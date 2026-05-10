import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';
import '../../../shared/utils/haptic_utils.dart';

import '../../alarms/cubit/alarm_cubit.dart';
import '../../alarms/cubit/alarm_state.dart';
import '../../alarms/screens/alarm_form_screen.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/bottom_nav_shell.dart';
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
      create: (_) => HomeCubit()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                        _WeekRow(weekDays: state.weekDays),
                        SizedBox(height: 24.h),
                        BlocBuilder<AlarmCubit, AlarmState>(
                          builder: (context, alarmState) {
                            final now = DateTime.now();
                            final upcoming = alarmState.alarms
                                .where((a) => a.isEnabled)
                                .map((a) => (
                                      alarm: a,
                                      fireAt: a.nextFireAt(now),
                                    ))
                                .where((e) => e.fireAt != null)
                                .toList()
                              ..sort(
                                (a, b) => a.fireAt!.compareTo(b.fireAt!),
                              );
                            final next = upcoming.isNotEmpty
                                ? upcoming.first.alarm
                                : null;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.homeNextAlarm,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: c.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                if (next != null)
                                  _NextAlarmCard(alarm: next)
                                else
                                  const _NoAlarmCard(),
                                SizedBox(height: 24.h),
                              ],
                            );
                          },
                        ),
                        BlocBuilder<AlarmCubit, AlarmState>(
                          builder: (context, alarmState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.alarmsTitle,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: c.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                if (alarmState.alarms.isEmpty)
                                  const _EmptyAlarmsCard()
                                else
                                  ...alarmState.alarms.map(
                                    (alarm) => Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: _AlarmCard(alarm: alarm),
                                    ),
                                  ),
                              ],
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
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final List<DayStatus> weekDays;
  const _WeekRow({required this.weekDays});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final todayIndex = now.weekday % 7; // 0=Sun

    final dates = List.generate(7, (i) {
      final diff = i - todayIndex;
      return now.add(Duration(days: diff));
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final isToday = i == todayIndex;
        final isFuture = i > todayIndex;
        final status = weekDays.length > i ? weekDays[i] : DayStatus.none;
        final dayNum = dates[i].day.toString();
        final label = localizedDayShort(l10n, i);

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
                  child: Center(
                    child: Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
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
            child: Center(
              child: Text(
                dayNum,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
            ),
          );
        } else if (status == DayStatus.frozen) {
          circle = Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.frozen, width: 2.5),
            ),
            child: Center(
              child: Text(
                dayNum,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
            ),
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
                dayNum,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: c.textSecondary.withAlpha(100),
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
              child: Center(
                child: Text(
                  dayNum,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: c.textSecondary,
                  ),
                ),
              ),
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

class _NoAlarmCard extends StatelessWidget {
  const _NoAlarmCard();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: withHaptic(() => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AlarmCubit>(),
                child: const AlarmFormScreen(),
              ),
            ),
          )),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: c.primary.withAlpha(60), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: c.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.add_alarm_rounded,
                color: c.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeNoActiveAlarm,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10n.homeNoActiveAlarmHint,
                    style:
                        TextStyle(fontSize: 13.sp, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _NextAlarmCard extends StatelessWidget {
  final AppAlarmEntry alarm;
  const _NextAlarmCard({required this.alarm});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final fireAt = alarm.nextFireAt(now) ?? alarm.dateTime;
    final diff = fireAt.difference(now);
    final hoursLeft = diff.inHours;
    final minsLeft = diff.inMinutes % 60;
    final timeStr = _formatTime(alarm.dateTime);
    final isPM = alarm.dateTime.hour >= 12;

    return GestureDetector(
      onTap: withHaptic(() => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AlarmCubit>(),
                child: AlarmFormScreen(alarm: alarm),
              ),
            ),
          )),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diff.isNegative
                  ? l10n.homeToday
                  : diff.inHours < 24
                      ? l10n.homeToday
                      : l10n.homeTomorrow,
              style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: c.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Text(
                    isPM ? 'pm' : 'am',
                    style:
                        TextStyle(fontSize: 16.sp, color: c.textSecondary),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: alarm.isEnabled,
                  activeThumbColor: c.primary,
                  onChanged: withHapticValue((val) =>
                      context.read<AlarmCubit>().toggleAlarm(alarm.id, val)),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 14.sp,
                  color: c.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  diff.isNegative
                      ? l10n.homePastAlarm
                      : l10n.homeRingsIn(hoursLeft, minsLeft),
                  style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AlarmCard extends StatelessWidget {
  final AppAlarmEntry alarm;
  const _AlarmCard({required this.alarm});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final t = alarm.dateTime;
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final isPM = t.hour >= 12;
    final dayStr = alarm.isOneTime
        ? l10n.alarmsOneTime
        : _daysLabel(l10n, alarm.repeatDays);

    return GestureDetector(
      onTap: withHaptic(() => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AlarmCubit>(),
                child: AlarmFormScreen(alarm: alarm),
              ),
            ),
          )),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayStr,
              style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
            ),
            SizedBox(height: 4.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$h:$m',
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    color: c.textPrimary,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
                  child: Text(
                    isPM ? 'PM' : 'AM',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: c.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Switch(
                    value: alarm.isEnabled,
                    activeThumbColor: c.primary,
                    onChanged: withHapticValue((val) => context
                        .read<AlarmCubit>()
                        .toggleAlarm(alarm.id, val)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  alarm.name.isNotEmpty
                      ? alarm.name
                      : l10n.alarmsDefaultName(1),
                  style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: withHaptic(
                      () => context.read<AlarmCubit>().removeAlarm(alarm.id)),
                  child: Icon(Icons.delete_outline,
                      size: 24.sp, color: c.textSecondary.withAlpha(140)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _daysLabel(AppLocalizations l10n, List<bool> days) {
    if (days.every((d) => d)) return l10n.alarmsEveryDay;
    if (days.every((d) => !d)) return l10n.alarmsOneTime;

    final selected = <String>[];
    for (int i = 0; i < days.length; i++) {
      if (days[i]) selected.add(localizedDayShort(l10n, i));
    }
    if (days[1] &&
        days[2] &&
        days[3] &&
        days[4] &&
        days[5] &&
        !days[0] &&
        !days[6]) {
      return l10n.alarmsWeekdays;
    }
    return selected.join(', ');
  }
}

class _EmptyAlarmsCard extends StatelessWidget {
  const _EmptyAlarmsCard();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.alarm_off_rounded, size: 48.sp, color: c.textSecondary),
            SizedBox(height: 12.h),
            Text(
              l10n.alarmsEmpty,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.alarmsEmptyHint,
              style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
