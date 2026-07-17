import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../../shared/widgets/appy_nav_bar.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_enums.dart';
import '../widgets/community_create_post_sheet.dart';
import '../widgets/community_feed_view.dart';
import '../widgets/community_groups_view.dart';
import '../widgets/community_messages_view.dart';
import '../widgets/community_segmented_control.dart';
import '../widgets/community_username_sheet.dart';
import 'user_search_screen.dart';

/// Community page (Feed / Groups / Messages). The [CommunityCubit] is provided
/// globally (see app.dart) and driven by the auth lifecycle.
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) => const _CommunityView();
}

class _CommunityView extends StatefulWidget {
  const _CommunityView();

  @override
  State<_CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<_CommunityView> {
  bool _gateShown = false;

  @override
  void initState() {
    super.initState();
    // A profile-less user may have been flagged before this page mounted (the
    // needsProfile transition fires at sign-in), so check on first build too.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeShowGate(context.read<CommunityCubit>().state);
    });
  }

  void _maybeShowGate(CommunityState state) {
    if (state.needsProfile && !_gateShown) {
      _gateShown = true;
      CommunityUsernameSheet.show(context);
    } else if (!state.needsProfile) {
      _gateShown = false;
    }
  }

  /// FAB action depends on the active segment: compose a post on the feed,
  /// start a new conversation on messages.
  void _onFab(BuildContext context, CommunityState state) {
    switch (state.segment) {
      case CommunitySegment.feed:
        CommunityCreatePostSheet.show(context);
      case CommunitySegment.messages:
        final uid = state.currentUid;
        if (uid == null) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => UserSearchScreen(currentUid: uid),
          ),
        );
      case CommunitySegment.groups:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<CommunityCubit, CommunityState>(
      // Gate interaction behind a username-setup sheet for users who onboarded
      // before community profiles existed.
      listenWhen: (p, c) => p.needsProfile != c.needsProfile,
      listener: (context, state) => _maybeShowGate(state),
      child: Scaffold(
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
        floatingActionButton: BlocBuilder<CommunityCubit, CommunityState>(
          buildWhen: (p, c) => p.segment != c.segment,
          builder: (context, state) {
            if (state.segment == CommunitySegment.groups) {
              return const SizedBox.shrink();
            }
            final icon = state.segment == CommunitySegment.messages
                ? Icons.edit_rounded
                : Icons.add_rounded;
            return Transform.translate(
              // Nudged a little down and to the left from the default corner.
              offset: Offset(-14.w, 16.h),
              child: GestureDetector(
                onTap: withHaptic(() => _onFab(context, state)),
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
                  child: Icon(icon, color: Colors.white, size: 30.sp),
                ),
              ),
            );
          },
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
      ),
    );
  }
}
