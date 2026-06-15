import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/mission.dart';
import '../models/mission_config.dart';
import 'mission_sequence_screen.dart';

/// Grid of all available missions. Tapping one starts it immediately via
/// [MissionSequenceScreen].
class MissionPickerScreen extends StatelessWidget {
  const MissionPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Exclude 'none' and 'random' from the picker grid.
    final missions = allMissions
        .where((m) => m.type != MissionType.random)
        .toList();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              size: 20.sp, color: c.textPrimary),
          onPressed: withHaptic(() => Navigator.of(context).pop()),
        ),
        centerTitle: true,
        title: Text(
          l10n.missionPickerTitle,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
            child: Text(
              l10n.missionPickerSubtitle,
              style: TextStyle(fontSize: 14.sp, color: c.textSecondary),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.1,
              ),
              itemCount: missions.length,
              itemBuilder: (context, i) =>
                  _MissionCard(info: missions[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final MissionInfo info;
  const _MissionCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: withMediumHaptic(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MissionSequenceScreen(
              missions: [MissionConfig(type: info.type)],
            ),
          ),
        );
      }),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18.r),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: info.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, color: info.iconColor, size: 22.sp),
            ),
            const Spacer(),
            Text(
              info.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              info.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.sp, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
