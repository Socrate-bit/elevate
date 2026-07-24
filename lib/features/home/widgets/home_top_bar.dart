import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/utils/haptic_utils.dart';
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
          // Right: settings.
          _IconButton(
            asset: 'assets/home/setting.png',
            size: 40,
            onTap: () {},
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
