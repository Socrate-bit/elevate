import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../adventure/cubit/adventure_cubit.dart';
import '../../adventure/cubit/adventure_state.dart';
import '../../adventure/models/game_profile.dart';
import '../../adventure/screens/adventure_success_screen.dart';
import '../cubit/heart_cubit.dart';
import '../cubit/heart_state.dart';

/// Teal quest banner with lightning icon, adventure title and a progress
/// pill / action button reflecting the live adventure state. The coin balance,
/// streak and shop shortcuts perch on the banner's top-right corner.
class QuestBanner extends StatelessWidget {
  const QuestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 18.w, left: 18.w, bottom: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Spacer(),
              const _CoinCounter(),
              SizedBox(width: 16.w),
              const _StreakSign(),
              SizedBox(width: 24.w),
              _PerchIcon(asset: 'assets/home_page/shop_icon.png', onTap: () {}),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Container(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
            decoration: BoxDecoration(
              // Just opacity — a translucent overlay over the green background.
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Image.asset('assets/home/light.png', width: 38.w),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.adventureTitle,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      const _AdventureSlot(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The pill / button below the adventure title. Swaps by adventure phase:
/// charging bar → Start button → loading bar → Discover button.
class _AdventureSlot extends StatelessWidget {
  const _AdventureSlot();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AdventureCubit, AdventureState>(
      builder: (context, adv) {
        if (adv.isArrived) {
          return _ActionButton(
            label: l10n.adventureDiscoverButton,
            onTap: () => _discover(context),
          );
        }
        if (adv.isWalking) {
          return _ProgressPill(
            progress: adv.walkProgress,
            label: _remainingLabel(l10n, adv.remaining),
          );
        }
        if (adv.isReady) {
          return _ActionButton(
            label: l10n.adventureStartButton,
            onTap: () => context.read<AdventureCubit>().startAdventure(),
          );
        }
        return _ProgressPill(
          progress: adv.chargeProgress,
          label: l10n.adventureStrikeProgress(adv.profile.strikes, kStrikeGoal),
        );
      },
    );
  }

  String _remainingLabel(AppLocalizations l10n, Duration d) =>
      l10n.adventureRemaining(d.inHours, d.inMinutes % 60);

  /// Claims the reward, then shows the full-screen success celebration.
  Future<void> _discover(BuildContext context) async {
    final nav = Navigator.of(context);
    final trophy = await context.read<AdventureCubit>().discover();
    if (trophy == null) return;
    await nav.push(
      MaterialPageRoute(
        builder: (_) => AdventureSuccessScreen(trophy: trophy),
      ),
    );
  }
}

/// White CTA button used for "Start Adventure" / "Discover the surprise".
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withMediumHaptic(onTap),
      child: Container(
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: HomePalette.progressYellow,
          borderRadius: BorderRadius.circular(21.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: HomePalette.progressBrown,
          ),
        ),
      ),
    );
  }
}

/// Circular shortcut icon that sits on top of the quest banner.
class _PerchIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _PerchIcon({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap),
      child: Image.asset(asset, width: 40.w, height: 40.w),
    );
  }
}

/// Live coin balance perched on the banner (no coin artwork exists yet, so a
/// Material coin icon is used).
class _CoinCounter extends StatelessWidget {
  const _CoinCounter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdventureCubit, AdventureState>(
      buildWhen: (a, b) => a.profile.coins != b.profile.coins,
      builder: (context, adv) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monetization_on_rounded,
              size: 34.w,
              color: HomePalette.progressYellow,
            ),
            SizedBox(width: 4.w),
            Text(
              '${adv.profile.coins}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Streak sign perched on the banner: the flame asset with the live streak
/// count. Reads the count from [HeartCubit], kept reactive to activity updates
/// and heart-driven streak breaks.
class _StreakSign extends StatelessWidget {
  const _StreakSign();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeartCubit, HeartState>(
      buildWhen: (a, b) => a.streak != b.streak,
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/home_page/streak_icon.png',
              width: 40.w,
              height: 40.w,
            ),
            SizedBox(width: 4.w),
            Text(
              '${state.streak}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// White pill progress bar with a yellow fill and centered label.
class _ProgressPill extends StatelessWidget {
  final double progress;
  final String label;

  const _ProgressPill({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 21.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Yellow fill — keeps a visible rounded nub even at 0 progress.
          FractionallySizedBox(
            widthFactor: (progress).clamp(0.07, 1.0),
            child: Container(
              margin: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: HomePalette.progressYellow,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
          ),
          Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.progressBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
