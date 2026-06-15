import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Minimalist composer: a translucent frosted "+" circle, a frosted pill with
/// the text field, and a trailing call/send icon. Reports text via [onSend].
class ChatComposerBar extends StatefulWidget {
  final ValueChanged<String> onSend;

  const ChatComposerBar({super.key, required this.onSend});

  @override
  State<ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<ChatComposerBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    widget.onSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Leading "+" — its own frosted translucent circle.
        _FrostedCircle(icon: Icons.add_rounded, onTap: () {}),
        SizedBox(width: 10.w),
        // Translucent pill holding the text field + call/send icon.
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.only(left: 18.w, right: 8.w),
                decoration: BoxDecoration(
                  color: ChatPalette.composer,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        textInputAction: TextInputAction.send,
                        style: TextStyle(
                          color: ChatPalette.composerText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                          border: InputBorder.none,
                          hintText: l10n.chatPageComposerHint,
                          hintStyle: TextStyle(
                            color: ChatPalette.composerHint,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: withHaptic(_send),
                      child: Padding(
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          Icons.call_rounded,
                          color: ChatPalette.composerText,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Translucent frosted circular action button.
class _FrostedCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FrostedCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 48.w,
            height: 48.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ChatPalette.composer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ChatPalette.composerText, size: 24.sp),
          ),
        ),
      ),
    );
  }
}
