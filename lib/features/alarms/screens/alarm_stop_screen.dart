import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elevate/features/alarms/cubit/alarm_cubit.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';
import '../services/alarm_cascade_controller.dart';
import '../../activity/services/activity_service.dart';
import '../../../shared/theme/app_theme.dart';

/// Screen shown when an alarm fires. User taps "Stop" to dismiss.
/// Logs an Activity record for streak/insights tracking.
class AlarmStopScreen extends StatefulWidget {
  final String alarmId;
  final String nativeAlarmId;
  final String alarmLabel;

  const AlarmStopScreen({
    super.key,
    required this.alarmId,
    required this.nativeAlarmId,
    this.alarmLabel = 'Alarm',
  });

  @override
  State<AlarmStopScreen> createState() => _AlarmStopScreenState();
}

class _AlarmStopScreenState extends State<AlarmStopScreen> {
  final _startTime = DateTime.now();
  late final AlarmCascadeController _cascade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _cascade = AlarmCascadeController(alarmId: widget.alarmId);
    _cascade.start();
  }

  @override
  void dispose() {
    _cascade.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _stop() async {
    HapticFeedback.mediumImpact();
    await _cascade.finish();

    final elapsed = DateTime.now().difference(_startTime).inSeconds;

    if (!mounted) return;
    final isOneTime = context.read<AlarmCubit>().state.alarms
        .any((a) => a.id == widget.alarmId && a.isOneTime);
    if (isOneTime) {
      // ignore: use_build_context_synchronously
      await context.read<AlarmCubit>().toggleAlarm(widget.alarmId, false);
    }

    final pending = await ActivityService.getPendingActivity(widget.alarmId);
    if (pending != null) {
      await ActivityService.completeActivity(
        pending.id,
        durationSeconds: elapsed,
      );
    }

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⏰', style: TextStyle(fontSize: 72.sp)),
                    SizedBox(height: 24.h),
                    Text(
                      widget.alarmLabel,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
              child: ElevatedButton(
                onPressed: _stop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 56.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.alarmStop,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
