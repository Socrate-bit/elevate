import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/mission.dart';
import '../models/mission_config.dart';
import 'mission_sequence_screen.dart';

/// Full mission picker with category filter tabs and a 2-column card grid.
/// Tapping a card starts the mission immediately via [MissionSequenceScreen].
/// The preview button runs the mission in preview mode (no completion flow).
class MissionPickerScreen extends StatefulWidget {
  const MissionPickerScreen({super.key});

  @override
  State<MissionPickerScreen> createState() => _MissionPickerScreenState();
}

class _MissionPickerScreenState extends State<MissionPickerScreen> {
  MissionCategory _filter = MissionCategory.all;

  List<MissionInfo> get _filtered {
    if (_filter == MissionCategory.all) return allMissions;
    return allMissions.where((m) => m.category == _filter).toList();
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
            // Header row
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: withHaptic(() => Navigator.pop(context)),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: c.card,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18.sp, color: c.textPrimary),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        l10n.missionPickerTitle,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 36.w),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Category filter chips
            SizedBox(
              height: 38.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: MissionCategory.values.map((cat) {
                  final label = switch (cat) {
                    MissionCategory.all => l10n.missionPickerAll,
                    MissionCategory.trending => l10n.missionPickerTrending,
                    MissionCategory.hunts => l10n.missionPickerHunts,
                    MissionCategory.physical => l10n.missionPickerPhysical,
                  };
                  final emoji = switch (cat) {
                    MissionCategory.all => '⚡',
                    MissionCategory.trending => '🔥',
                    MissionCategory.hunts => '🔍',
                    MissionCategory.physical => '💪',
                  };
                  final selected = _filter == cat;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: withHaptic(() => setState(() => _filter = cat)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.orange : c.card,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '$emoji $label',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : c.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
            // Mission grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) => _MissionCard(info: _filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final MissionInfo info;
  const _MissionCard({required this.info});

  void _start(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MissionSequenceScreen(
          missions: [MissionConfig(type: info.type)],
        ),
      ),
    );
  }

  void _preview(BuildContext context) {
    final screen = buildMissionScreen(
      config: MissionConfig(type: info.type),
      isPreview: true,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: withMediumHaptic(() => _start(context)),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: info.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(info.icon, color: info.iconColor, size: 26.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              info.name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              info.description,
              style: TextStyle(fontSize: 12.sp, color: c.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Preview button
            GestureDetector(
              onTap: withHaptic(() => _preview(context)),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 14.sp, color: c.textSecondary),
                    SizedBox(width: 2.w),
                    Text(
                      l10n.missionPickerPreview,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
