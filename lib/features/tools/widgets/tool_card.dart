import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../missions/screens/breathing_mission_screen.dart';
import '../cubit/gratitude_cubit.dart';
import '../models/tools_mock_data.dart';
import '../screens/gratitude_tool_session_screen.dart';
import '../screens/video_tool_session_screen.dart';

/// A single square tool/activity card: asset icon on top, title + subtitle
/// centered below. Sized to fill its (square) grid cell.
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
      case ToolAction.gratitude:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => GratitudeCubit(),
            child: const GratitudeToolSessionScreen(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(item.iconAsset, width: 44.w, height: 44.w),
            SizedBox(height: 10.h),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.titleDark,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                height: 1.2,
                color: HomePalette.subtitleGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
