import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_cubit.dart';
import '../cubit/community_post_detail_cubit.dart';
import '../cubit/community_post_detail_state.dart';
import '../models/community_comment.dart';
import '../models/community_post.dart';
import '../utils/community_time.dart';

/// Post detail: the post plus its full comment thread and an add-comment field.
class CommunityPostDetailScreen extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityPostDetailCubit(post.id),
      child: _PostDetailView(post: post),
    );
  }
}

class _PostDetailView extends StatefulWidget {
  final CommunityPost post;

  const _PostDetailView({required this.post});

  @override
  State<_PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<_PostDetailView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final profile = context.read<CommunityCubit>().state.profile;
    if (profile == null) return;
    context.read<CommunityPostDetailCubit>().addComment(profile, text);
    _controller.clear();
    FocusScope.of(context).unfocus();
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
          l10n.communityCommentsTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: CommunityPalette.textDark,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommunityPostDetailCubit,
                CommunityPostDetailState>(
              builder: (context, state) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  children: [
                    _PostHeader(post: widget.post),
                    SizedBox(height: 16.h),
                    if (!state.isLoading && state.comments.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 24.h),
                        child: Center(
                          child: Text(
                            l10n.communityNoComments,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: CommunityPalette.subtitleGrey,
                            ),
                          ),
                        ),
                      ),
                    for (final comment in state.comments) ...[
                      _CommentRow(comment: comment),
                      SizedBox(height: 12.h),
                    ],
                  ],
                );
              },
            ),
          ),
          _CommentComposer(controller: _controller, onSend: _submit),
        ],
      ),
    );
  }
}

/// Read-only rendering of the post being discussed.
class _PostHeader extends StatelessWidget {
  final CommunityPost post;

  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: CommunityPalette.card,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.w,
                backgroundColor: CommunityPalette.background,
                backgroundImage: AssetImage(post.authorAvatarAsset),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  post.authorUsername,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: CommunityPalette.textDark,
                  ),
                ),
              ),
              Text(
                communityTimeAgo(post.createdAt),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: CommunityPalette.subtitleGrey,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            post.body,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.4,
              color: CommunityPalette.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final CommunityComment comment;

  const _CommentRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16.w,
          backgroundColor: CommunityPalette.card,
          backgroundImage: AssetImage(comment.authorAvatarAsset),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: CommunityPalette.card,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorUsername,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: CommunityPalette.textDark,
                        ),
                      ),
                    ),
                    Text(
                      communityTimeAgo(comment.createdAt),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: CommunityPalette.subtitleGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  comment.body,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.35,
                    color: CommunityPalette.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _CommentComposer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 8.h),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: CommunityPalette.card,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CommunityPalette.textDark,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: l10n.communityCommentHint,
                    hintStyle: TextStyle(color: CommunityPalette.subtitleGrey),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: withHaptic(onSend),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: CommunityPalette.fab,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
