import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elevate/l10n/generated/app_localizations.dart';
import 'package:elevate/l10n/l10n_helpers.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  List<Activity>? _activities;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ActivityService.getActivities(limit: 50, includeIncomplete: true),
      ActivityService.getTotalActivities(),
    ]);
    if (!mounted) return;
    setState(() {
      _activities = results[0] as List<Activity>;
      _total = results[1] as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: GestureDetector(
                onTap: withHaptic(() => Navigator.pop(context)),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: c.textPrimary,
                    ),
                    Expanded(
                      child: Text(
                        l10n.activityHistoryTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _activities == null
                  ? const Center(child: CircularProgressIndicator())
                  : _activities!.isEmpty
                      ? Center(
                          child: Text(
                            l10n.activityHistoryEmpty,
                            style: TextStyle(
                                fontSize: 15.sp, color: c.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                          itemCount: _activities!.length,
                          separatorBuilder: (context, i) =>
                              SizedBox(height: 10.h),
                          itemBuilder: (context, i) {
                            final activity = _activities![i];
                            final number = _total - i;
                            return _ActivityTile(
                              activity: activity,
                              number: number,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final int number;

  const _ActivityTile({
    required this.activity,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final ts = activity.timestamp;
    final h = ts.hour > 12 ? ts.hour - 12 : (ts.hour == 0 ? 12 : ts.hour);
    final isPM = ts.hour >= 12;
    final timeStr =
        '$h:${ts.minute.toString().padLeft(2, '0')} ${isPM ? 'pm' : 'am'}';
    final dateStr = '${localizedMonth(l10n, ts.month)} ${ts.day}';

    final mins = activity.durationSeconds ~/ 60;
    final secs = activity.durationSeconds % 60;
    final durationStr = mins > 0 ? '${mins}m ${secs}s' : '${secs}s';

    final missed = !activity.completed;
    final iconColor = missed ? c.textSecondary : c.primary;
    final iconBg =
        missed ? c.textSecondary.withAlpha(20) : c.primary.withAlpha(25);

    return Opacity(
      opacity: missed ? 0.6 : 1.0,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                missed ? Icons.alarm_off_outlined : Icons.check_circle_outline,
                color: iconColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    missed ? l10n.activityHistoryMissed : activity.type,
                    style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                ),
                SizedBox(height: 2.h),
                if (!missed)
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 12.sp, color: c.textSecondary),
                      SizedBox(width: 3.w),
                      Text(
                        durationStr,
                        style: TextStyle(fontSize: 12.sp, color: c.textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
