import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/community_mock_data.dart';

/// A single feed post: author header, body, and reactions row.
class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar, username + tag, time, menu.
          Row(
            children: [
              CircleAvatar(
                radius: 18.w,
                backgroundColor: CommunityPalette.background,
                backgroundImage: AssetImage(post.avatar),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: CommunityPalette.textDark,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _TagPill(tag: post.tag),
                  ],
                ),
              ),
              Text(
                post.timeAgo,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: CommunityPalette.subtitleGrey,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.more_horiz_rounded,
                size: 18.sp,
                color: CommunityPalette.subtitleGrey,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Body.
          Text(
            post.body,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.4,
              color: CommunityPalette.textDark,
            ),
          ),
          SizedBox(height: 12.h),
          // Reactions.
          Row(
            children: [
              _Reaction(
                icon: post.liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                count: post.likes,
                color: post.liked
                    ? CommunityPalette.heart
                    : CommunityPalette.reactionGrey,
                onTap: onLike,
              ),
              SizedBox(width: 18.w),
              _Reaction(
                icon: Icons.chat_bubble_outline_rounded,
                count: post.comments,
                color: CommunityPalette.reactionGrey,
                onTap: () {},
              ),
              SizedBox(width: 18.w),
              _Reaction(
                icon: Icons.people_alt_outlined,
                count: post.shares,
                color: CommunityPalette.reactionGrey,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Category pill (e.g. Anxiety, Depression).
class _TagPill extends StatelessWidget {
  final String tag;
  const _TagPill({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: CommunityPalette.tagBg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: CommunityPalette.tagText,
        ),
      ),
    );
  }
}

/// An icon + count reaction button.
class _Reaction extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _Reaction({
    required this.icon,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
