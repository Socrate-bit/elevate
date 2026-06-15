import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/utils/haptic_utils.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';
import '../cubit/alarm_cubit.dart';
import '../cubit/alarm_state.dart';
import '../../../shared/theme/app_theme.dart';
import 'alarm_form_screen.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AlarmCubit, AlarmState>(
      builder: (context, state) {
        final bottomPadding = MediaQuery.viewPaddingOf(context).bottom + 60;
        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            title: Text(l10n.alarmsTitle),
          ),
          body: Stack(
            children: [
              state.alarms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('⏰', style: TextStyle(fontSize: 56.sp)),
                          SizedBox(height: 16.h),
                          Text(
                            l10n.alarmsEmpty,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            l10n.alarmsEmptyHint,
                            style: TextStyle(
                                fontSize: 14.sp, color: c.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                          20.w, 16.h, 20.w, bottomPadding + 72),
                      itemCount: state.alarms.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (ctx, i) =>
                          _AlarmCard(alarm: state.alarms[i]),
                    ),
              Positioned(
                right: 20.w,
                bottom: bottomPadding + 10,
                child: FloatingActionButton(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  onPressed: withHaptic(() => _addAlarm(context)),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addAlarm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AlarmCubit>(),
          child: const AlarmFormScreen(),
        ),
      ),
    );
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
                      size: 18.sp, color: c.textSecondary),
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
