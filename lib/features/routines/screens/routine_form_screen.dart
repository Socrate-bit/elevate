import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/routine_cubit.dart';
import '../models/routine.dart';
import '../models/routine_palette.dart';
import '../widgets/color_swatch_row.dart';
import '../widgets/icon_picker_sheet.dart';

class RoutineFormScreen extends StatefulWidget {
  /// Non-null = edit mode.
  final Routine? routine;

  /// Default type when creating. Ignored when editing.
  final RoutineType initialType;

  const RoutineFormScreen({
    super.key,
    this.routine,
    this.initialType = RoutineType.action,
  });

  @override
  State<RoutineFormScreen> createState() => _RoutineFormScreenState();
}

class _RoutineFormScreenState extends State<RoutineFormScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _objectCtrl;
  late RoutineType _type;
  late String _iconKey;
  late String _colorKey;
  late List<bool> _scheduledDays;
  DateTime? _scheduledDate;
  int? _scheduledMinute;
  bool _hasAlarm = false;

  bool get _isEditing => widget.routine != null;
  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final r = widget.routine;
    if (r != null) {
      _nameCtrl = TextEditingController(text: r.name);
      _descCtrl = TextEditingController(text: r.description ?? '');
      _objectCtrl = TextEditingController(text: r.objectCheck ?? '');
      _type = r.type;
      _iconKey = r.iconKey;
      _colorKey = r.colorKey;
      _scheduledDays = List<bool>.from(r.scheduledDays);
      _scheduledDate = r.scheduledDate;
      _scheduledMinute = r.scheduledMinute;
      _hasAlarm = r.hasAlarm;
    } else {
      _nameCtrl = TextEditingController();
      _descCtrl = TextEditingController();
      _objectCtrl = TextEditingController();
      _type = widget.initialType;
      _iconKey = kDefaultRoutineIconKey;
      _colorKey = kDefaultRoutineColorKey;
      _scheduledDays = _type == RoutineType.habit
          ? [false, true, true, true, true, true, false]
          : [false, false, false, false, false, false, false];
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _objectCtrl.dispose();
    super.dispose();
  }

  void _showTimePicker() {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    var hour = (_scheduledMinute ?? 8 * 60) ~/ 60;
    var minute = (_scheduledMinute ?? 0) % 60;
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
                  if (_scheduledMinute != null)
                    GestureDetector(
                      onTap: withHaptic(() {
                        setState(() {
                          _scheduledMinute = null;
                          _hasAlarm = false;
                        });
                        Navigator.pop(ctx);
                      }),
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: Text(
                          l10n.routineFormClear,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: withHaptic(() {
                      setState(() => _scheduledMinute = hour * 60 + minute);
                      Navigator.pop(ctx);
                    }),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
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
                      scrollController:
                          FixedExtentScrollController(initialItem: hour),
                      itemExtent: 40.h,
                      onSelectedItemChanged: (i) => hour = i,
                      children: List.generate(
                        24,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: TextStyle(
                                fontSize: 22.sp, color: c.textPrimary),
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
                      scrollController:
                          FixedExtentScrollController(initialItem: minute),
                      itemExtent: 40.h,
                      onSelectedItemChanged: (i) => minute = i,
                      children: List.generate(
                        60,
                        (i) => Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: TextStyle(
                                fontSize: 22.sp, color: c.textPrimary),
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _scheduledDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _scheduledDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tint = routineColor(_colorKey);
    final timeSet = _scheduledMinute != null;

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
                    SizedBox(height: 12.h),
                    _Header(
                      title: _isEditing
                          ? l10n.routineFormEditTitle
                          : (_type == RoutineType.action
                              ? l10n.routineFormNewAction
                              : l10n.routineFormNewHabit),
                      onClose: () => Navigator.pop(context),
                      onDelete: _isEditing ? _confirmDelete : null,
                    ),
                    SizedBox(height: 20.h),
                    _IconColorRow(
                      iconKey: _iconKey,
                      tint: tint,
                      onPickIcon: () async {
                        final picked = await showIconPickerSheet(
                          context,
                          selectedKey: _iconKey,
                          tint: tint,
                        );
                        if (picked != null) setState(() => _iconKey = picked);
                      },
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
                          hintText: l10n.routineFormNameHint,
                          hintStyle: TextStyle(color: c.textSecondary),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _FormCard(
                      child: TextField(
                        controller: _descCtrl,
                        maxLines: null,
                        style:
                            TextStyle(fontSize: 15.sp, color: c.textPrimary),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: l10n.routineFormDescriptionHint,
                          hintStyle: TextStyle(color: c.textSecondary),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _FormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.routineFormColorLabel,
                            style: TextStyle(
                                fontSize: 13.sp, color: c.textSecondary),
                          ),
                          SizedBox(height: 12.h),
                          ColorSwatchRow(
                            selectedKey: _colorKey,
                            onChanged: (key) =>
                                setState(() => _colorKey = key),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _FormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.routineFormObjectCheckLabel,
                            style: TextStyle(
                                fontSize: 13.sp, color: c.textSecondary),
                          ),
                          SizedBox(height: 4.h),
                          TextField(
                            controller: _objectCtrl,
                            style: TextStyle(
                                fontSize: 17.sp, color: c.textPrimary),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: l10n.routineFormObjectCheckHint,
                              hintStyle: TextStyle(color: c.textSecondary),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (_type == RoutineType.action)
                      _FormCard(
                        onTap: _pickDate,
                        child: Row(
                          children: [
                            Text(
                              l10n.routineFormDateLabel,
                              style: TextStyle(
                                  fontSize: 17.sp, color: c.textPrimary),
                            ),
                            const Spacer(),
                            if (_scheduledDate != null) ...[
                              GestureDetector(
                                onTap: withHaptic(
                                    () => setState(() => _scheduledDate = null)),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: Icon(Icons.close,
                                      size: 18.sp, color: c.textSecondary),
                                ),
                              ),
                              Text(
                                _formatDate(_scheduledDate!),
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: c.textPrimary,
                                ),
                              ),
                            ] else
                              Text(
                                l10n.routineFormPickDate,
                                style: TextStyle(
                                    fontSize: 17.sp, color: c.textSecondary),
                              ),
                            SizedBox(width: 4.w),
                            Icon(Icons.chevron_right,
                                size: 22.sp, color: c.textSecondary),
                          ],
                        ),
                      ),
                    if (_type == RoutineType.habit)
                      _FormCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.alarmFormRepeatOn,
                              style: TextStyle(
                                  fontSize: 13.sp, color: c.textSecondary),
                            ),
                            SizedBox(height: 12.h),
                            _DayToggles(
                              days: _scheduledDays,
                              tint: tint,
                              onChanged: (i) {
                                setState(() {
                                  _scheduledDays = List.from(_scheduledDays)
                                    ..[i] = !_scheduledDays[i];
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 12.h),
                    _FormCard(
                      onTap: _showTimePicker,
                      child: Row(
                        children: [
                          Text(
                            l10n.alarmFormAlarmTime,
                            style: TextStyle(
                                fontSize: 17.sp, color: c.textPrimary),
                          ),
                          const Spacer(),
                          Text(
                            timeSet
                                ? _formatTime(_scheduledMinute!)
                                : l10n.routineFormPickTime,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight:
                                  timeSet ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  timeSet ? c.textPrimary : c.textSecondary,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.routineFormAlarmLabel,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    color: timeSet
                                        ? c.textPrimary
                                        : c.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  l10n.routineFormAlarmHint,
                                  style: TextStyle(
                                      fontSize: 12.sp, color: c.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _hasAlarm && timeSet,
                            activeThumbColor: c.primary,
                            onChanged: timeSet
                                ? withHapticValue(
                                    (val) => setState(() => _hasAlarm = val))
                                : null,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: GestureDetector(
                onTap: _canSave ? withHaptic(_save) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: _canSave ? tint : c.textSecondary.withAlpha(60),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      _isEditing
                          ? l10n.alarmFormSaveChanges
                          : l10n.routineFormCreate,
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

  void _save() {
    final cubit = context.read<RoutineCubit>();
    final draft = (widget.routine ??
            Routine(
              id: '',
              type: _type,
              name: '',
              iconKey: _iconKey,
              colorKey: _colorKey,
            ))
        .copyWith(
      type: _type,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      clearDescription: _descCtrl.text.trim().isEmpty,
      iconKey: _iconKey,
      colorKey: _colorKey,
      objectCheck: _objectCtrl.text.trim().isEmpty
          ? null
          : _objectCtrl.text.trim(),
      clearObjectCheck: _objectCtrl.text.trim().isEmpty,
      scheduledDate:
          _type == RoutineType.action ? _scheduledDate : null,
      clearScheduledDate:
          _type != RoutineType.action || _scheduledDate == null,
      scheduledDays: _type == RoutineType.habit
          ? _scheduledDays
          : const [false, false, false, false, false, false, false],
      scheduledMinute: _scheduledMinute,
      clearScheduledMinute: _scheduledMinute == null,
      hasAlarm: _hasAlarm && _scheduledMinute != null,
    );

    if (_isEditing) {
      cubit.editRoutine(draft);
    } else {
      cubit.addRoutine(draft);
    }
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.routineFormDeleteTitle),
        content: Text(l10n.routineFormDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.routineFormDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.routineFormDeleteConfirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final routine = widget.routine!;
    await context.read<RoutineCubit>().removeRoutine(routine.id);
    if (mounted) Navigator.pop(context);
  }

  String _formatTime(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback? onDelete;

  const _Header({required this.title, required this.onClose, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: withHaptic(onClose),
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: c.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8),
              ],
            ),
            child: Icon(Icons.close, size: 20.sp, color: c.textPrimary),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (onDelete != null)
          GestureDetector(
            onTap: withHaptic(onDelete),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: c.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8),
                ],
              ),
              child: Icon(Icons.delete_outline,
                  size: 20.sp, color: c.textSecondary),
            ),
          )
        else
          SizedBox(width: 40.w),
      ],
    );
  }
}

class _IconColorRow extends StatelessWidget {
  final String iconKey;
  final Color tint;
  final VoidCallback onPickIcon;

  const _IconColorRow({
    required this.iconKey,
    required this.tint,
    required this.onPickIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onPickIcon),
      child: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: tint,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: tint.withAlpha(80), blurRadius: 16),
          ],
        ),
        child: Icon(routineIcon(iconKey), color: Colors.white, size: 36.sp),
      ),
    );
  }
}

class _DayToggles extends StatelessWidget {
  final List<bool> days;
  final Color tint;
  final ValueChanged<int> onChanged;

  const _DayToggles({
    required this.days,
    required this.tint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.daySingleSun,
      l10n.daySingleMon,
      l10n.daySingleTue,
      l10n.daySingleWed,
      l10n.daySingleThu,
      l10n.daySingleFri,
      l10n.daySingleSat,
    ];
    return Row(
      children: List.generate(7, (i) {
        final selected = days[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                left: i == 0 ? 0 : 4.w, right: i == 6 ? 0 : 4.w),
            child: GestureDetector(
              onTap: withHaptic(() => onChanged(i)),
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? tint : c.background,
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
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
      child: Container(
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
