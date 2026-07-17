import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Top icon row: quests + shop on the left, settings on the right.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _IconButton(
            asset: 'assets/home/quests.png',
            size: 46,
            onTap: () {},
          ),
          _IconButton(
            asset: 'assets/home/shop.png',
            size: 46,
            onTap: () {},
          ),
          _IconButton(
            asset: 'assets/home/setting.png',
            size: 38,
            badge: const _CheckBadge(),
            badgeBottom: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Asset icon button with an optional badge overlay.
class _IconButton extends StatelessWidget {
  final String asset;
  final double size;
  final Widget? badge;
  final bool badgeBottom;
  final VoidCallback onTap;

  const _IconButton({
    required this.asset,
    required this.size,
    required this.onTap,
    this.badge,
    this.badgeBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: SizedBox(
        width: size.w + 8.w,
        height: size.w + 8.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: Image.asset(asset, width: size.w, height: size.w),
            ),
            if (badge != null)
              Positioned(
                right: badgeBottom ? -2.w : 0,
                top: badgeBottom ? null : 0,
                bottom: badgeBottom ? -2.w : null,
                child: badge!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Green circular check badge (settings).
class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: HomePalette.checkGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Icon(Icons.check_rounded, color: Colors.white, size: 14.sp),
    );
  }
}
