import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../companion/cubit/companion_cubit.dart';

/// Chat header: the companion name centered over the scene, with an optional
/// [trailing] widget pinned to the right (e.g. the insight progress button).
class ChatTopBar extends StatelessWidget {
  final Widget? trailing;

  const ChatTopBar({super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final companionName = context.watch<CompanionCubit>().state;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$companionName 🌿',
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ChatPalette.headerTitle,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}
