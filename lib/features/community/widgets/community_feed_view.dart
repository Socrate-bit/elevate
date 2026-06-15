import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import 'community_check_in_card.dart';
import 'community_filter_chips.dart';
import 'community_post_card.dart';
import 'daily_inspiration_card.dart';

/// Feed segment: filter chips, inspiration + check-in cards, then posts.
class CommunityFeedView extends StatelessWidget {
  const CommunityFeedView({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Posts react to like toggles.
              BlocBuilder<CommunityCubit, CommunityState>(
                buildWhen: (p, c) => p.posts != c.posts,
                builder: (context, state) {
                  return Column(
                    children: [
                      for (var i = 0; i < state.posts.length; i++) ...[
                        CommunityPostCard(
                          post: state.posts[i],
                          onLike: () =>
                              context.read<CommunityCubit>().toggleLike(i),
                        ),
                        if (i != state.posts.length - 1) SizedBox(height: 12.h),
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
