import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../adventure/cubit/adventure_cubit.dart';
import '../../adventure/cubit/adventure_state.dart';
import '../../settings/screens/settings_screen.dart';
import '../../shop/cubit/shop_cubit.dart';
import '../../shop/cubit/shop_state.dart';
import '../cubit/streak_cubit.dart';
import '../cubit/streak_state.dart';
import '../services/heart_service.dart';

/// Top bar over the scene: "Appy" name with a row of hearts on the left, and
/// the settings icon aligned to the right.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: name + hearts.
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appy',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              BlocBuilder<StreakCubit, StreakState>(
                buildWhen: (a, b) => a.hearts != b.hearts,
                builder: (context, state) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < kHeartMax; i++)
                      Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: Image.asset(
                          i < state.hearts
                              ? 'assets/home_page/heart_icon.png'
                              : 'assets/home_page/heartempty_icon.png',
                          width: 32.w,
                          height: 32.w,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Right: settings — swapped for the live coin balance while the
          // shop modal is open.
          BlocBuilder<ShopCubit, ShopState>(
            buildWhen: (a, b) => a.isOpen != b.isOpen,
            builder: (context, shop) => shop.isOpen
                ? const _CoinBalance()
                : _IconButton(
                    asset: 'assets/home/setting.png',
                    size: 40,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Asset icon button, bottom-aligned within its tap target.
class _IconButton extends StatelessWidget {
  final String asset;
  final double size;
  final VoidCallback onTap;

  const _IconButton({
    required this.asset,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Image.asset(asset, width: size.w, height: size.w),
    );
  }
}

/// Live coin balance pill shown in place of the settings icon while the shop
/// modal is open.
class _CoinBalance extends StatelessWidget {
  const _CoinBalance();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdventureCubit, AdventureState>(
      buildWhen: (a, b) => a.profile.coins != b.profile.coins,
      builder: (context, adv) => Container(
        height: 40.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monetization_on_rounded,
              size: 24.w,
              color: HomePalette.progressYellow,
            ),
            SizedBox(width: 6.w),
            Text(
              '${adv.profile.coins}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.progressBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
