import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_enums.dart';

/// Feed / Groups / Messages selector — a rounded track with a dark-brown pill
/// that slides to the selected segment. Each segment is fully tappable; the
/// Groups segment shows an orange count badge.
class CommunitySegmentedControl extends StatelessWidget {
  const CommunitySegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CommunityCubit, CommunityState>(
      buildWhen: (p, c) =>
          p.segment != c.segment ||
          p.groups.length != c.groups.length ||
          p.unreadTotal != c.unreadTotal,
      builder: (context, state) {
        final groupsBadge = state.groups.isEmpty ? null : state.groups.length;
        final unreadBadge = state.unreadTotal == 0 ? null : state.unreadTotal;
        final items = <(CommunitySegment, IconData, String, int?)>[
          (
            CommunitySegment.feed,
            Icons.dashboard_rounded,
            l10n.communityFeed,
            null,
          ),
          (
            CommunitySegment.groups,
            Icons.groups_rounded,
            l10n.communityGroups,
            groupsBadge,
          ),
          (
            CommunitySegment.messages,
            Icons.mail_rounded,
            l10n.communityMessages,
            unreadBadge,
          ),
        ];
        final index = items.indexWhere((e) => e.$1 == state.segment);
        return Container(
          height: 48.h,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: CommunityPalette.segmentTrack,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segWidth = constraints.maxWidth / items.length;
              return Stack(
                children: [
                  // Sliding selection pill (behind the labels).
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    left: index * segWidth,
                    top: 0,
                    bottom: 0,
                    width: segWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: CommunityPalette.segmentSelected,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  // Fully tappable segments on top.
                  Row(
                    children: [
                      for (final (segment, icon, label, badge) in items)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: withHaptic(
                              () => context
                                  .read<CommunityCubit>()
                                  .selectSegment(segment),
                            ),
                            child: _SegmentContent(
                              icon: icon,
                              label: label,
                              badge: badge,
                              selected: state.segment == segment,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Centered icon + label (+ optional badge) filling its segment cell. Text is
/// white over the selected pill, brown otherwise.
class _SegmentContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int? badge;

  const _SegmentContent({
    required this.icon,
    required this.label,
    required this.selected,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : CommunityPalette.segmentText;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17.sp, color: fg),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
          if (badge != null) ...[
            SizedBox(width: 5.w),
            Container(
              width: 18.w,
              height: 18.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: CommunityPalette.groupsBadge,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badge',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
