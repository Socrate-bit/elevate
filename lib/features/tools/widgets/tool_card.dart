import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/tools_mock_data.dart';
import '../tools_launcher.dart';

/// A single square tool/activity card: asset icon on top, title + subtitle
/// centered below. Sized to fill its (square) grid cell.
///
/// By default a tap opens the tool's guided session ([openToolSession]); pass
/// [onTap] to override (e.g. the add-task sheet adds it to the plan instead).
class ToolCard extends StatelessWidget {
  final ToolItem item;
  final VoidCallback? onTap;

  const ToolCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap ?? () => openToolSession(context, item)),
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
