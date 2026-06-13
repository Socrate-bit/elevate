import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_mock_data.dart';

/// Feed / Groups / Messages pill row. The selected segment is filled dark
/// brown; the Groups segment shows an orange count badge.
class CommunitySegmentedControl extends StatelessWidget {
  const CommunitySegmentedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CommunityCubit, CommunityState>(
      buildWhen: (p, c) => p.segment != c.segment,
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: _SegmentTab(
                icon: Icons.dashboard_rounded,
                label: l10n.communityFeed,
                selected: state.segment == CommunitySegment.feed,
                onTap: () => context
                    .read<CommunityCubit>()
                    .selectSegment(CommunitySegment.feed),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SegmentTab(
                icon: Icons.groups_rounded,
                label: l10n.communityGroups,
                selected: state.segment == CommunitySegment.groups,
                badge: CommunityMockData.groupsCount,
                onTap: () => context
                    .read<CommunityCubit>()
                    .selectSegment(CommunitySegment.groups),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _SegmentTab(
                icon: Icons.mail_rounded,
                label: l10n.communityMessages,
                selected: state.segment == CommunitySegment.messages,
                onTap: () => context
                    .read<CommunityCubit>()
                    .selectSegment(CommunitySegment.messages),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A single segment pill.
class _SegmentTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : CommunityPalette.segmentText;
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        height: 42.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? CommunityPalette.segmentSelected
              : CommunityPalette.card,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: fg),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
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
      ),
    );
  }
}
