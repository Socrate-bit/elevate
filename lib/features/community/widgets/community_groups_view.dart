import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/community_mock_data.dart';

/// Groups segment: a list of joinable support groups.
class CommunityGroupsView extends StatelessWidget {
  const CommunityGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    const groups = CommunityMockData.groups;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      itemCount: groups.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, i) => _GroupCard(group: groups[i]),
    );
  }
}

/// A single group card.
class _GroupCard extends StatelessWidget {
  final CommunityGroup group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: CommunityPalette.card,
        borderRadius: BorderRadius.circular(20.r),
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
          CircleAvatar(
            radius: 24.w,
            backgroundColor: CommunityPalette.background,
            backgroundImage: AssetImage(group.avatar),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: CommunityPalette.textDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.communityMembersCount(group.members),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: CommunityPalette.textBrown,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  group.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.3,
                    color: CommunityPalette.subtitleGrey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          _JoinPill(joined: group.joined),
        ],
      ),
    );
  }
}

/// Join / Joined action pill.
class _JoinPill extends StatelessWidget {
  final bool joined;
  const _JoinPill({required this.joined});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: withHaptic(() {}),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: joined
              ? CommunityPalette.joinedPill
              : CommunityPalette.joinPill,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          joined ? l10n.communityGroupJoined : l10n.communityGroupJoin,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: joined ? CommunityPalette.textBrown : Colors.white,
          ),
        ),
      ),
    );
  }
}
