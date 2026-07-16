import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../missions/screens/breathing_mission_screen.dart';
import '../models/tools_mock_data.dart';
import '../screens/video_tool_session_screen.dart';

/// A single tool/activity card: square asset icon on the left, title + subtitle
/// stacked on the right. Sized to fill its grid cell.
class ToolCard extends StatelessWidget {
  final ToolItem item;

  const ToolCard({super.key, required this.item});

  /// Routes the tapped tool to its guided session (or nowhere for [ToolAction.none]).
  void _open(BuildContext context) {
    switch (item.action) {
      case ToolAction.breathing:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const BreathingMissionScreen(isPreview: true),
        ));
      case ToolAction.video:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => VideoToolSessionScreen(
            title: item.title,
            videoUrl: item.videoUrl!,
          ),
        ));
      case ToolAction.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Launch the tool's guided session; cards with no action stay selection-only.
      onTap: withHaptic(() => _open(context)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: HomePalette.cardWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(item.iconAsset, width: 38.w, height: 38.w),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: HomePalette.titleDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      height: 1.1,
                      color: HomePalette.subtitleGrey,
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
}
