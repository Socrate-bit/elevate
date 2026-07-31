import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../adventure/cubit/adventure_cubit.dart';
import '../../adventure/cubit/adventure_state.dart';
import '../../trophy/cubit/trophy_reveal_cubit.dart';
import '../../trophy/screens/trophy_reveal_screen.dart';
import '../../shop/cubit/shop_cubit.dart';
import '../../shop/cubit/shop_state.dart';
import '../../shop/widgets/shop_sheet.dart';
import '../cubit/streak_cubit.dart';
import '../cubit/streak_state.dart';
import '../screens/streak_detail_screen.dart';

/// Teal quest banner with lightning icon, adventure title and a progress
/// pill / action button reflecting the live adventure state. The coin balance
/// and shop shortcut perch on the banner's top-right corner.
class QuestBanner extends StatelessWidget {
  const QuestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Streak + shop shortcut — hidden while the shop modal is open (its
        // slot is kept so the banner below doesn't shift).
        BlocBuilder<ShopCubit, ShopState>(
          buildWhen: (a, b) => a.isOpen != b.isOpen,
          builder: (context, shop) => Visibility(
            visible: !shop.isOpen,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Padding(
              padding: EdgeInsets.only(right: 18.w, left: 18.w, bottom: 12.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Current level — sits opposite the streak + shop icons.
                  const _LevelBadge(),
                  const Spacer(),
                  const _StreakCounter(),
                  SizedBox(width: 24.w),
                  _PerchIcon(
                    asset: 'assets/home_page/shop_icon.png',
                    onTap: () => showShopSheet(context),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Container(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
            decoration: BoxDecoration(
              // Just opacity — a translucent overlay over the green bg.
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: BlocBuilder<AdventureCubit, AdventureState>(
              builder: (context, adv) {
                // Action phases: a big white button inside the banner replaces
                // the "aventure en forêt" title + the strike/progress pill.
                if (adv.isArrived) {
                  return _BigActionButton(
                    label: l10n.adventureDiscoverButton,
                    onTap: () => _discover(context),
                  );
                }
                if (adv.isReady) {
                  return _BigActionButton(
                    label: l10n.adventureStartButton,
                    onTap: () =>
                        context.read<AdventureCubit>().startAdventure(),
                  );
                }
                // Charging / walking: lightning + title + progress pill.
                return Row(
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
                          _ProgressPill(
                            progress: adv.isWalking
                                ? adv.walkProgress
                                : adv.chargeProgress,
                            label: adv.isWalking
                                ? l10n.adventureRemaining(
                                    _clock(adv.remaining))
                                : l10n.adventureStrikeProgress(
                                    adv.profile.strikes, adv.profile.strikeGoal),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Remaining walk time as a plain HH:MM:SS clock (e.g. "16:15:23").
  String _clock(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Opens the reward reveal, which generates the citation, saves the trophy,
  /// and resets the adventure.
  void _discover(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TrophyRevealCubit()..reveal(),
          child: const TrophyRevealScreen(),
        ),
      ),
    );
  }
}

/// Big white CTA that fills the banner for "Start Adventure" / "Discover".
class _BigActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BigActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withMediumHaptic(onTap),
      child: Container(
        width: double.infinity,
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
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

/// Current adventure level, shown above the level-progression (adventure) bar.
/// Rebuilds only when the level changes.
class _LevelBadge extends StatelessWidget {
  const _LevelBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AdventureCubit, AdventureState>(
      buildWhen: (a, b) => a.profile.level != b.profile.level,
      builder: (context, adv) => Text(
        l10n.levelLabel(adv.profile.level),
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Live daily-streak count perched on the banner (consecutive days with a
/// completed activity).
class _StreakCounter extends StatelessWidget {
  const _StreakCounter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakCubit, StreakState>(
      buildWhen: (a, b) => a.streak != b.streak,
      builder: (context, state) {
        return GestureDetector(
          onTap: withHaptic(() => showStreakDetailSheet(context)),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/home_page/streak_icon.png', width: 40.w),
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
          ),
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
      height: 28.h,
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
                fontSize: 14.sp,
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
