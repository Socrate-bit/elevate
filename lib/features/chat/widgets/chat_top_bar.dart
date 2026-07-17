import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';

/// Chat header: just the companion name centered over the scene.
class ChatTopBar extends StatelessWidget {
  const ChatTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        '${l10n.chatPageCompanionName} 🌿',
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: ChatPalette.headerTitle,
          fontSize: 16.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
