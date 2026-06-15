import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../../shared/widgets/appy_nav_bar.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_mock_data.dart';
import '../widgets/community_feed_view.dart';
import '../widgets/community_groups_view.dart';
import '../widgets/community_messages_view.dart';
import '../widgets/community_segmented_control.dart';

/// Community page — pure UI on mock data (Feed / Groups / Messages).
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityCubit(),
      child: const _CommunityView(),
    );
  }
}

class _CommunityView extends StatelessWidget {
  const _CommunityView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: CommunityPalette.background,
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: CommunityPalette.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.communityTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: CommunityPalette.textDark,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: withHaptic(() {}),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 24.sp,
              color: CommunityPalette.textDark,
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      floatingActionButton: Transform.translate(
        // Nudged a little down and to the left from the default corner.
        offset: Offset(-14.w, 16.h),
        child: GestureDetector(
          onTap: withHaptic(() {}),
          child: Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: CommunityPalette.fab,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 30.sp),
          ),
        ),
      ),
      bottomNavigationBar: const AppyNavBar(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
            child: const CommunitySegmentedControl(),
          ),
          Expanded(
            child: BlocBuilder<CommunityCubit, CommunityState>(
              buildWhen: (p, c) => p.segment != c.segment,
              builder: (context, state) {
                switch (state.segment) {
                  case CommunitySegment.feed:
                    return const CommunityFeedView();
                  case CommunitySegment.groups:
                    return const CommunityGroupsView();
                  case CommunitySegment.messages:
                    return const CommunityMessagesView();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
