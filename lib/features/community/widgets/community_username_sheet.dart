import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';

/// Non-dismissible sheet that prompts existing users (who onboarded before
/// community profiles existed) to pick a username before interacting.
class CommunityUsernameSheet extends StatefulWidget {
  const CommunityUsernameSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<CommunityCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const CommunityUsernameSheet(),
      ),
    );
  }

  @override
  State<CommunityUsernameSheet> createState() => _CommunityUsernameSheetState();
}

class _CommunityUsernameSheetState extends State<CommunityUsernameSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: CommunityPalette.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.communitySetUsernameTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: CommunityPalette.textDark,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                l10n.communitySetUsernameSubtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: CommunityPalette.subtitleGrey,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  color: CommunityPalette.card,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CommunityPalette.textDark,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: l10n.onboardingUsernameLabel,
                    hintStyle: TextStyle(color: CommunityPalette.subtitleGrey),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: withHaptic(() {
                  final username = _controller.text.trim();
                  if (username.isEmpty) return;
                  context.read<CommunityCubit>().createProfile(username);
                  Navigator.of(context).pop();
                }),
                child: Container(
                  height: 52.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: CommunityPalette.fab,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    l10n.communitySave,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
