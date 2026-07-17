import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/community_dm_cubit.dart';
import '../cubit/community_dm_state.dart';
import '../models/community_conversation.dart';
import '../models/community_dm_message.dart';
import '../utils/community_time.dart';

/// A 1:1 direct-message conversation.
class CommunityDmScreen extends StatelessWidget {
  final CommunityConversation conversation;
  final String currentUid;

  const CommunityDmScreen({
    super.key,
    required this.conversation,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommunityDmCubit(conversation, currentUid),
      child: _CommunityDmView(
        conversation: conversation,
        currentUid: currentUid,
      ),
    );
  }
}

class _CommunityDmView extends StatefulWidget {
  final CommunityConversation conversation;
  final String currentUid;

  const _CommunityDmView({required this.conversation, required this.currentUid});

  @override
  State<_CommunityDmView> createState() => _CommunityDmViewState();
}

class _CommunityDmViewState extends State<_CommunityDmView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<CommunityDmCubit>().send(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final otherUid = widget.conversation.otherUid(widget.currentUid);
    return Scaffold(
      backgroundColor: CommunityPalette.background,
      appBar: AppBar(
        backgroundColor: CommunityPalette.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: CommunityPalette.textDark),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16.w,
              backgroundColor: CommunityPalette.card,
              backgroundImage:
                  AssetImage(widget.conversation.avatarAssetFor(otherUid)),
            ),
            SizedBox(width: 10.w),
            Text(
              widget.conversation.usernameFor(otherUid),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: CommunityPalette.textDark,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommunityDmCubit, CommunityDmState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.messages.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                  itemCount: state.messages.length,
                  itemBuilder: (context, i) {
                    // reverse: render newest at the bottom.
                    final msg =
                        state.messages[state.messages.length - 1 - i];
                    return _MessageBubble(
                      message: msg,
                      isMine: msg.senderUid == widget.currentUid,
                    );
                  },
                );
              },
            ),
          ),
          _Composer(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final CommunityDmMessage message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        constraints: BoxConstraints(maxWidth: 260.w),
        decoration: BoxDecoration(
          color: isMine
              ? CommunityPalette.segmentSelected
              : CommunityPalette.card,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.body,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.35,
                color: isMine ? Colors.white : CommunityPalette.textDark,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              communityTimeAgo(message.createdAt),
              style: TextStyle(
                fontSize: 9.sp,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.7)
                    : CommunityPalette.subtitleGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _Composer({required this.controller, required this.onSend});

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
                    hintText: l10n.communityMessageHint,
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
