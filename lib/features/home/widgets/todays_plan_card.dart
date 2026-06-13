import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/home_page_cubit.dart';
import '../models/home_mock_data.dart';

/// "Today's Plan" section (Finch-style): a header on the green background, then
/// each task in its own white card.
class TodaysPlanCard extends StatelessWidget {
  final List<HomePlanItem> items;

  const TodaysPlanCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 90.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: sun, title + subtitle (white over green), Edit pill.
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: Colors.white),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homePageTodaysPlan,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.homePageTodaysPlanSubtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              // Plain white edit icon.
              GestureDetector(
                onTap: withHaptic(() {}),
                child: Icon(
                  Icons.add,
                  size: 30.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Hold a card to drag and reorder.
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) => context
                .read<HomePageCubit>()
                .reorderPlanItem(oldIndex, newIndex),
            // Keep the dragged proxy looking like the card (no extra Material).
            proxyDecorator: (child, index, animation) => child,
            itemBuilder: (context, i) {
              return ReorderableDelayedDragStartListener(
                key: ValueKey(items[i].title),
                index: i,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _TaskCard(
                    item: items[i],
                    onToggle: () =>
                        context.read<HomePageCubit>().togglePlanItem(i),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One task as a white card: icon tile, title + subtitle, XP and check button.
class _TaskCard extends StatelessWidget {
  final HomePlanItem item;
  final VoidCallback onToggle;

  const _TaskCard({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: HomePalette.cardWhite,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag handle — affordance that the card can be reordered.
          Icon(
            Icons.drag_indicator,
            size: 18.sp,
            color: HomePalette.subtitleGrey.withValues(alpha: 0.5),
          ),
          SizedBox(width: 6.w),
          // Circular icon tile.
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.tileColor,
              shape: BoxShape.circle,
            ),
            child: Text(item.emoji, style: TextStyle(fontSize: 22.sp)),
          ),
          SizedBox(width: 12.w),
          // Title + subtitle.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: HomePalette.titleDark,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: HomePalette.subtitleGrey,
                  ),
                ),
              ],
            ),
          ),
          // XP reward: number + lightning.
          Text(
            '${item.xp}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: HomePalette.titleDark,
            ),
          ),
          SizedBox(width: 3.w),
          Image.asset('assets/home/light.png', width: 16.w),
          SizedBox(width: 10.w),
          _CheckButton(done: item.done, onTap: onToggle),
        ],
      ),
    );
  }
}

/// Tappable check button: grey rounded square; green check when done.
class _CheckButton extends StatelessWidget {
  final bool done;
  final VoidCallback onTap;

  const _CheckButton({required this.done, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: done ? HomePalette.teal: HomePalette.checkButtonBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: done ? HomePalette.teal : HomePalette.checkButtonBorder,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.check_rounded,
          size: 22.sp,
          color: done ? Colors.white : HomePalette.checkButtonBorder,
        ),
      ),
    );
  }
}
