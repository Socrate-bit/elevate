import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/tools_mock_data.dart';
import 'tool_card.dart';

/// A titled group of tool cards: emoji + colored header, then a 2-column grid.
class ToolSectionWidget extends StatelessWidget {
  final ToolSection section;

  /// Header text color (section accent from the design).
  final Color titleColor;

  const ToolSectionWidget({
    super.key,
    required this.section,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header: emoji + bold accent title.
        Row(
          children: [
            Text(section.emoji, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            Text(
              section.title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // 2-column grid of cards with a fixed row height.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: section.items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 64.h,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
          ),
          itemBuilder: (context, i) => ToolCard(item: section.items[i]),
        ),
      ],
    );
  }
}
