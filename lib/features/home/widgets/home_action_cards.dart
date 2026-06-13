import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../models/home_mock_data.dart';

/// Row of the three quick-action cards: Message, Call, Crisis Mode.
class HomeActionCards extends StatelessWidget {
  const HomeActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: _ActionCard(
              label: l10n.homePageMessage,
              icon: Image.asset('assets/home/message.png', height: 38.w),
              badge: HomeMockData.messageBadge,
              onTap: () {},
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 4,
            child: _ActionCard(
              label: l10n.homePageCall,
              icon: Image.asset('assets/home/phone.png', height: 38.w),
              onTap: () {},
            ),
          ),
          SizedBox(width: 10.w),
          // Crisis card: same height, 1.25x the width of the others.
          Expanded(
            flex: 5,
            child: _ActionCard(
              label: l10n.homePageCrisisMode,
              icon: Image.asset('assets/home/crisis.png', height: 38.w),
              crisis: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded action card with an icon, label and optional red badge.
class _ActionCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final String? badge;
  final bool crisis;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
    this.badge,
    this.crisis = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Container(
        height: 92.h,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: crisis ? HomePalette.crisisRed : HomePalette.cardWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border(
            bottom: BorderSide(
              color: crisis
                  ? HomePalette.crisisRedDark
                  : const Color(0x14000000),
              width: 4,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                icon,
                if (badge != null)
                  Positioned(
                    right: -8.w,
                    top: -6.w,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: HomePalette.badgeRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            // Scale down instead of overflowing on long labels (e.g. FR).
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: crisis ? Colors.white : HomePalette.titleDark,
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
