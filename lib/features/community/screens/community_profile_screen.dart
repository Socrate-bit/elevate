import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_state.dart';
import '../models/community_profile.dart';
import 'community_dm_screen.dart';

/// A community member's public profile with a "Send message" action.
class CommunityProfileScreen extends StatelessWidget {
  final CommunityProfile profile;

  const CommunityProfileScreen({super.key, required this.profile});

  Future<void> _openConversation(BuildContext context, String currentUid) async {
    final cubit = context.read<CommunityCubit>();
    final conversation = await cubit.openConversationWith(profile);
    if (conversation == null || !context.mounted) return;
    Navigator.of(context).push(
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
      ),
      body: BlocBuilder<CommunityCubit, CommunityState>(
        buildWhen: (p, c) => p.currentUid != c.currentUid,
        builder: (context, state) {
          final currentUid = state.currentUid;
          final isSelf = currentUid == profile.uid;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),
                CircleAvatar(
                  radius: 48.w,
                  backgroundColor: CommunityPalette.card,
                  backgroundImage: AssetImage(profile.avatarAsset),
                ),
                SizedBox(height: 16.h),
                Text(
                  profile.username,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: CommunityPalette.textDark,
                  ),
                ),
                SizedBox(height: 24.h),
                if (!isSelf && currentUid != null)
                  GestureDetector(
                    onTap: withHaptic(
                      () => _openConversation(context, currentUid),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 52.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: CommunityPalette.fab,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.communitySendMessage,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
