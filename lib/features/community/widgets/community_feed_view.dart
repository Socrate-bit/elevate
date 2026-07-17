import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_post.dart';
import '../models/community_profile.dart';
import '../screens/community_post_detail_screen.dart';
import '../screens/community_profile_screen.dart';
import 'community_check_in_card.dart';
import 'community_filter_chips.dart';
import 'community_post_card.dart';
import 'daily_inspiration_card.dart';

/// Feed segment: filter chips, inspiration + check-in cards, then posts.
class CommunityFeedView extends StatelessWidget {
  const CommunityFeedView({super.key});

  void _openPost(BuildContext context, CommunityPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityPostDetailScreen(post: post),
      ),
    );
  }

  void _openAuthor(BuildContext context, CommunityPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityProfileScreen(
          profile: CommunityProfile(
            uid: post.authorUid,
            username: post.authorUsername,
            avatarId: post.authorAvatarId,
            createdAt: post.createdAt,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: EdgeInsets.fromLTRB(0, 12.h, 0, 100.h),
      children: [
        const CommunityFilterChips(),
        SizedBox(height: 14.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              const DailyInspirationCard(),
              SizedBox(height: 12.h),
              const CommunityCheckInCard(),
              SizedBox(height: 12.h),
              BlocBuilder<CommunityCubit, CommunityState>(
                buildWhen: (p, c) =>
                    p.posts != c.posts ||
                    p.filter != c.filter ||
                    p.currentUid != c.currentUid,
                builder: (context, state) {
                  final posts = state.filteredPosts;
                  if (posts.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: 32.h),
                      child: Text(
                        l10n.communityFeedEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: CommunityPalette.subtitleGrey,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < posts.length; i++) ...[
                        CommunityPostCard(
                          post: posts[i],
                          currentUid: state.currentUid,
                          onLike: () =>
                              context.read<CommunityCubit>().toggleLike(posts[i]),
                          onShare: () =>
                              context.read<CommunityCubit>().sharePost(posts[i]),
                          onOpen: () => _openPost(context, posts[i]),
                          onOpenAuthor: () => _openAuthor(context, posts[i]),
                        ),
                        if (i != posts.length - 1) SizedBox(height: 12.h),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
