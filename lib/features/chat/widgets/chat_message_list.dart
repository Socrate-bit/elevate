import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../routines/cubit/routine_cubit.dart';
import '../cubit/chat_cubit.dart';
import '../services/chat_message.dart';
import 'chat_form_card.dart';
import 'chat_insight_card.dart';
import 'chat_mood_check_in_card.dart';
import 'chat_routine_card.dart';

/// Scrollable conversation over the illustrated scene. Renders (in order):
/// a frosted day separator whenever the calendar day changes, then Appy bubbles
/// / interactive cards on the left and user bubbles on the right, plus a typing
/// indicator while the model is replying. Driven by the real [ChatMessage]s from
/// [ChatCubit]; text bubbles keep a wide left inset while cards use full width.
class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isSending;
  final ScrollController controller;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.isSending,
    required this.controller,
  });

  /// Flattens [messages] into render items, injecting a day separator before
  /// the first message of each new calendar day and a typing item at the end.
  List<_ChatItem> _buildItems() {
    final items = <_ChatItem>[];
    DateTime? lastDay;
    for (final m in messages) {
      final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      if (lastDay == null || day != lastDay) {
        items.add(_DaySeparatorItem(day));
        lastDay = day;
      }
      items.add(_MessageItem(m));
    }
    if (isSending) items.add(const _TypingItem());
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _DaySeparatorItem) return _DayPill(day: item.day);
        if (item is _TypingItem) return const _TypingBubble();
        return _MessageRow(message: (item as _MessageItem).message);
      },
    );
  }
}

/// Marker types for the flattened render list.
sealed class _ChatItem {
  const _ChatItem();
}

class _DaySeparatorItem extends _ChatItem {
  final DateTime day;
  const _DaySeparatorItem(this.day);
}

class _MessageItem extends _ChatItem {
  final ChatMessage message;
  const _MessageItem(this.message);
}

class _TypingItem extends _ChatItem {
  const _TypingItem();
}

/// Centered frosted date separator that scrolls with the conversation. Shows
/// "Today"/"Yesterday" for recent days, else a localized medium date.
class _DayPill extends StatelessWidget {
  final DateTime day;
  const _DayPill({required this.day});

  String _label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return l10n.chatPageToday;
    if (diff == 1) return l10n.chatPageYesterday;
    return MaterialLocalizations.of(context).formatMediumDate(day);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: ChatPalette.glassPill,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                _label(context),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dispatches a single message to the right renderer: interactive card for
/// tool messages (empty text + one payload), otherwise a plain text bubble.
class _MessageRow extends StatelessWidget {
  final ChatMessage message;
  const _MessageRow({required this.message});

  @override
  Widget build(BuildContext context) {
    final m = message;
    final isModel = m.role == ChatRole.model;

    // Interactive cards are always model turns. Dispatch order:
    // form → mood → routine → insight → text.
    if (isModel && m.form != null) {
      return _CardWrap(
        child: ChatFormCard(
          form: m.form!,
          onAnswer: (idx) => context.read<ChatCubit>().answerForm(m.id, idx),
        ),
      );
    }
    if (isModel && m.moodCheckIn != null) {
      return _CardWrap(
        child: ChatMoodCheckInCard(messageId: m.id, checkIn: m.moodCheckIn!),
      );
    }
    if (isModel && m.routineMutation != null) {
      final mutation = m.routineMutation!;
      return _CardWrap(
        child: ChatRoutineCard(
          mutation: mutation,
          onStartNow: () => _startRoutineNow(context, mutation.routineId),
        ),
      );
    }
    if (isModel && m.insight != null) {
      return _CardWrap(child: ChatInsightCard(insight: m.insight!));
    }
    return _TextBubble(message: m);
  }

  Future<void> _startRoutineNow(BuildContext context, String routineId) async {
    final l10n = AppLocalizations.of(context)!;
    final routineCubit = context.read<RoutineCubit>();
    final chatCubit = context.read<ChatCubit>();
    try {
      await routineCubit.validate(routineId);
      debugPrint('[ChatMessageList] action validated: $routineId');
    } catch (e) {
      debugPrint('[ChatMessageList] validate failed: $e');
    }
    await chatCubit.sendText(l10n.chatActionCompleted);
  }
}

/// Full-width wrapper for interactive cards (no wide left inset, unlike bubbles).
class _CardWrap extends StatelessWidget {
  final Widget child;
  const _CardWrap({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 3.h),
    child: child,
  );
}

/// A plain text bubble — user (right, green) or Appy (left, frosted white).
/// Text bubbles carry a wide left inset so they read as a right-shifted column
/// over the scene, matching the illustrated design.
class _TextBubble extends StatelessWidget {
  final ChatMessage message;
  const _TextBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.72;
    final isUser = message.role == ChatRole.user;

    final bubble = isUser
        ? _UserBubble(message: message, maxWidth: maxWidth)
        : _AppyBubble(text: message.text, maxWidth: maxWidth);

    return Padding(
      padding: EdgeInsets.only(left: 6.w, top: 3.h, bottom: 3.h, right: 6.w),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: bubble,
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  final double maxWidth;
  const _UserBubble({required this.message, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(message.createdAt));
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: ChatPalette.userBubble,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(18.r),
            bottomRight: Radius.circular(4.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                message.text,
                style: TextStyle(
                  color: ChatPalette.userText,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Text(
                time,
                style: TextStyle(
                  color: ChatPalette.timestamp,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppyBubble extends StatelessWidget {
  final String text;
  final double maxWidth;
  const _AppyBubble({required this.text, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: ChatPalette.appyBubble,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(4.r),
            bottomRight: Radius.circular(18.r),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: ChatPalette.appyText,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

/// Three-dot typing indicator in an Appy-styled frosted bubble.
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 94.w, top: 3.h, bottom: 3.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: ChatPalette.appyBubble,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              topRight: Radius.circular(18.r),
              bottomLeft: Radius.circular(4.r),
              bottomRight: Radius.circular(18.r),
            ),
          ),
          child: SizedBox(
            width: 36.w,
            height: 8.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (_) => Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: ChatPalette.appyText,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
