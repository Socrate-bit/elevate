import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';

/// Bottom sheet to compose and publish a new community post.
class CommunityCreatePostSheet extends StatefulWidget {
  const CommunityCreatePostSheet({super.key});

  /// Shows the sheet over [context] (which must be under the global
  /// [CommunityCubit] provider).
  static Future<void> show(BuildContext context) {
    final cubit = context.read<CommunityCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const CommunityCreatePostSheet(),
      ),
    );
  }

  @override
  State<CommunityCreatePostSheet> createState() =>
      _CommunityCreatePostSheetState();
}

class _CommunityCreatePostSheetState extends State<CommunityCreatePostSheet> {
  final _controller = TextEditingController();
  int _tagIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tags = [
      l10n.communityTagAnxiety,
      l10n.communityTagDepression,
      l10n.communityTagMindfulness,
      l10n.communityTagRecovery,
      l10n.communityTagSleep,
      l10n.communityTagGeneral,
    ];
    return Padding(
      // Lift above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: CommunityPalette.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle.
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: CommunityPalette.tagBg,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.communityNewPostTitle,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: CommunityPalette.textDark,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              l10n.communityCategoryLabel,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: CommunityPalette.textBrown,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (var i = 0; i < tags.length; i++)
                  GestureDetector(
                    onTap: withHaptic(() => setState(() => _tagIndex = i)),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: _tagIndex == i
                            ? CommunityPalette.chipSelected
                            : CommunityPalette.card,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        tags[i],
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: _tagIndex == i
                              ? CommunityPalette.chipSelectedText
                              : CommunityPalette.textBrown,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: CommunityPalette.card,
                borderRadius: BorderRadius.circular(16.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 5,
                minLines: 3,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CommunityPalette.textDark,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.communityPostHint,
                  hintStyle: TextStyle(color: CommunityPalette.subtitleGrey),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: withHaptic(() {
                final body = _controller.text.trim();
                if (body.isEmpty) return;
                context
                    .read<CommunityCubit>()
                    .createPost(tag: tags[_tagIndex], body: body);
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
                  l10n.communityPostButton,
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
    );
  }
}
