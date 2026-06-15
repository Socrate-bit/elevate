import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../services/chat_conversation.dart';

/// One row in the conversation history list.
class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final title = conversation.title.isEmpty
        ? l10n.chatUntitledConversation
        : conversation.title;

    return GestureDetector(
      onTap: withHaptic(onTap),
      onLongPress: withHaptic(() => _confirmDelete(context)),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _relativeTime(context, conversation.lastMessageAt),
                    style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 22.sp, color: c.textSecondary),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chatDeleteConfirm),
        actions: [
          TextButton(
            onPressed: withHaptic(() => Navigator.pop(ctx)),
            child: Text(l10n.chatDeleteCancel),
          ),
          TextButton(
            onPressed: withHaptic(() {
              Navigator.pop(ctx);
              onDelete();
            }),
            child: Text(l10n.chatDelete),
          ),
        ],
      ),
    );
  }

  String _relativeTime(BuildContext context, DateTime when) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(when);
    if (diff.inSeconds < 30) return l10n.chatRelativeJustNow;
    if (diff.inMinutes < 1) return l10n.chatRelativeSecondsAgo(diff.inSeconds);
    if (diff.inHours < 1) return l10n.chatRelativeMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.chatRelativeHoursAgo(diff.inHours);
    return l10n.chatRelativeDaysAgo(diff.inDays);
  }
}
