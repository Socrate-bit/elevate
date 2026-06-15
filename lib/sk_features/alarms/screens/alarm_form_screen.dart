import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/utils/haptic_utils.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../cubit/alarm_cubit.dart';
import '../cubit/alarm_state.dart';
import '../../../shared/theme/app_theme.dart';

class AlarmFormScreen extends StatefulWidget {
  /// If non-null, the form is in edit mode for this alarm.
  final AppAlarmEntry? alarm;

  const AlarmFormScreen({super.key, this.alarm});

  @override
  State<AlarmFormScreen> createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends State<AlarmFormScreen> {
  late final TextEditingController _nameCtrl;
  late TimeOfDay _time;
  late bool _isScheduled;
  late List<bool> _repeatDays;

  bool get _isEditing => widget.alarm != null;

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final a = widget.alarm;
    if (a != null) {
      _nameCtrl = TextEditingController(text: a.name);
      _time = TimeOfDay(hour: a.dateTime.hour, minute: a.dateTime.minute);
      _isScheduled = !a.isOneTime;
      _repeatDays = List.from(a.repeatDays);
    } else {
      final alarmCount = context.read<AlarmCubit>().state.alarms.length;
      _nameCtrl = TextEditingController(text: 'Alarm #${alarmCount + 1}');
      _time = const TimeOfDay(hour: 8, minute: 0);
      _isScheduled = true;
      _repeatDays = [false, true, true, true, true, true, false];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _showTimePicker(AppColors c) {
    final l10n = AppLocalizations.of(context)!;
    var hour = _time.hour;
    var minute = _time.minute;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  Text(
                    l10n.alarmFormSetTime,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: withHaptic(() {
                      setState(
                        () => _time = TimeOfDay(hour: hour, minute: minute),
                      );
                      Navigator.pop(ctx);
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        l10n.alarmFormDone,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200.h,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: hour,
                      ),
                      itemExtent: 40.h,
                      onSelectedItemChanged: (i) => hour = i,
                      children: List.generate(
                        24,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 22.sp,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: c.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: minute,
                      ),
                      itemExtent: 40.h,
                      onSelectedItemChanged: (i) => minute = i,
                      children: List.generate(
                        60,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 22.sp,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dayLabels = [
      l10n.daySingleSun,
      l10n.daySingleMon,
      l10n.daySingleTue,
      l10n.daySingleWed,
      l10n.daySingleThu,
      l10n.daySingleFri,
      l10n.daySingleSat,
    ];
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 12.h, 0, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: withHaptic(() => Navigator.pop(context)),
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: c.card,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(12),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                size: 20.sp,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                _isEditing
                                    ? l10n.alarmFormEditAlarm
                                    : l10n.alarmFormNewAlarm,
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 40.w),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _FormCard(
                      child: TextField(
                        controller: _nameCtrl,
                        onChanged: (_) => setState(() {}),
                        style:
                            TextStyle(fontSize: 17.sp, color: c.textPrimary),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.alarmFormAlarmName,
                          hintStyle: TextStyle(color: c.textSecondary),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _FormCard(
                      onTap: () => _showTimePicker(c),
                      child: Row(
                        children: [
                          Text(
                            l10n.alarmFormAlarmTime,
                            style: TextStyle(
                                fontSize: 17.sp, color: c.textPrimary),
                          ),
                          const Spacer(),
                          Text(
                            _time.format(context),
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.chevron_right,
                              size: 22.sp, color: c.textSecondary),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _FormCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: _TogglePill(
                              label: l10n.alarmFormScheduled,
                              selected: _isScheduled,
                              onTap: () =>
                                  setState(() => _isScheduled = true),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _TogglePill(
                              label: l10n.alarmFormOneTime,
                              selected: !_isScheduled,
                              onTap: () =>
                                  setState(() => _isScheduled = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (_isScheduled) ...[
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.alarmFormRepeatOn,
                              style: TextStyle(
                                  fontSize: 15.sp, color: c.textSecondary),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: List.generate(7, (i) {
                                final selected = _repeatDays[i];
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: i == 0 ? 0 : 4.w,
                                      right: i == 6 ? 0 : 4.w,
                                    ),
                                    child: GestureDetector(
                                      onTap: withHaptic(() {
                                        setState(() {
                                          _repeatDays = List.from(_repeatDays)
                                            ..[i] = !selected;
                                        });
                                      }),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 150),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selected
                                                ? c.primary
                                                : c.background,
                                          ),
                                          child: Center(
                                            child: Text(
                                              dayLabels[i],
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: selected
                                                    ? Colors.white
                                                    : c.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: GestureDetector(
                onTap: _canSave ? withHaptic(() => _save(context)) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: _canSave ? c.primary : c.textSecondary.withAlpha(60),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      _isEditing
                          ? l10n.alarmFormSaveChanges
                          : l10n.alarmFormCreateAlarm,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    final entry = AppAlarmEntry(
      id: widget.alarm?.id ?? '',
      dateTime: dt,
      name: _nameCtrl.text.trim(),
      repeatDays: _repeatDays,
      isOneTime: !_isScheduled,
    );

    final cubit = context.read<AlarmCubit>();
    if (_isEditing) {
      cubit.editAlarm(widget.alarm!, entry);
    } else {
      cubit.addAlarm(entry);
    }
    Navigator.pop(context);
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _FormCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: child,
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TogglePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.background,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : c.textSecondary,
          ),
        ),
      ),
    );
  }
}
