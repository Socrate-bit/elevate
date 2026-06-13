import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Chat header: "Calm mode" pill (left), companion title + subtitle (center),
/// settings gear (right). All surfaces are frosted glass over the scene.
class ChatTopBar extends StatelessWidget {
  const ChatTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Left: calm-mode dropdown pill.
          _FrostedPill(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌿', style: TextStyle(fontSize: 11.sp)),
                SizedBox(width: 5.w),
                Text(
                  l10n.chatPageCalmMode,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ],
            ),
          ),
          // Center: companion title + subtitle.
          Expanded(
            child: Column(
              children: [
                Text(
                  '${l10n.chatPageCompanionName} 🌿',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ChatPalette.headerTitle,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  l10n.chatPageCompanionSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ChatPalette.headerSubtitle,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Right: settings gear.
          _FrostedPill(
            circular: true,
            onTap: () {},
            child: Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Translucent frosted pill used for the header controls.
class _FrostedPill extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool circular;

  const _FrostedPill({
    required this.child,
    required this.onTap,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(circular ? 100.r : 20.r);
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: circular
                ? EdgeInsets.all(9.w)
                : EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: ChatPalette.glassPill,
              borderRadius: radius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
