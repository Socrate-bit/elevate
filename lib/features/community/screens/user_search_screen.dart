import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';
import '../cubit/user_search_cubit.dart';
import '../cubit/user_search_state.dart';
import '../models/community_profile.dart';
import 'community_dm_screen.dart';

/// Searchable user list for starting a new direct-message conversation.
class UserSearchScreen extends StatelessWidget {
  final String currentUid;

  const UserSearchScreen({super.key, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserSearchCubit(excludeUid: currentUid),
      child: _UserSearchView(currentUid: currentUid),
    );
  }
}

class _UserSearchView extends StatelessWidget {
  final String currentUid;

  const _UserSearchView({required this.currentUid});

  Future<void> _openConversation(
    BuildContext context,
    CommunityProfile other,
  ) async {
    final community = context.read<CommunityCubit>();
    final conversation = await community.openConversationWith(other);
    if (conversation == null || !context.mounted) return;
    // Replace search with the conversation so Back returns to the list.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CommunityDmScreen(
          conversation: conversation,
          currentUid: currentUid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: CommunityPalette.background,
      appBar: AppBar(
        backgroundColor: CommunityPalette.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: CommunityPalette.textDark),
        title: Text(
          l10n.communityNewMessageTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: CommunityPalette.textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: CommunityPalette.card,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: CommunityPalette.subtitleGrey,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      onChanged: (v) =>
                          context.read<UserSearchCubit>().search(v),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CommunityPalette.textDark,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: l10n.communitySearchUsersHint,
                        hintStyle:
                            TextStyle(color: CommunityPalette.subtitleGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<UserSearchCubit, UserSearchState>(
              builder: (context, state) {
                if (state.isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.query.trim().isNotEmpty && state.results.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.communityNoUsersFound,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CommunityPalette.subtitleGrey,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                  itemCount: state.results.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (context, i) {
                    final profile = state.results[i];
                    return GestureDetector(
                      onTap: withHaptic(
                        () => _openConversation(context, profile),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: CommunityPalette.card,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.w,
                              backgroundColor: CommunityPalette.background,
                              backgroundImage:
                                  AssetImage(profile.avatarAsset),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                profile.username,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: CommunityPalette.textDark,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: CommunityPalette.subtitleGrey,
                              size: 22.sp,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
