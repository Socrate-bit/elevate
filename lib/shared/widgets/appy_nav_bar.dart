import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../app_nav_cubit.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_utils.dart';

/// Liquid-glass bottom navigation bar (5 tabs) driven by [AppNavCubit].
/// Shared by the Appy Home and Chat pages.
class AppyNavBar extends StatelessWidget {
  const AppyNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AppNavCubit, int>(
      builder: (context, selectedIndex) {
        return GlassBottomBar(
          tabs: [
            GlassBottomBarTab(
              thickness: 1,
              label: l10n.navHome,
              icon: const Icon(Icons.home_rounded),
            ),
            GlassBottomBarTab(
              label: l10n.navChat,
              icon: const Icon(Icons.chat_rounded),
            ),
            GlassBottomBarTab(
              label: l10n.navJournal,
              icon: const Icon(Icons.menu_book_rounded),
            ),
            GlassBottomBarTab(
              thickness: 1,
              label: l10n.navTools,
              icon: const Icon(Icons.spa_rounded),
            ),
          ],
          selectedIndex: selectedIndex,
          onTabSelected: withHapticValue(
            context.read<AppNavCubit>().selectTab,
          )!,
          barHeight: 60.h,
          horizontalPadding: 24.w,
          verticalPadding: 20.h,
          iconSize: 30.sp,
          labelFontSize: 10.sp,
          iconLabelSpacing: 1,
          selectedIconColor: HomePalette.teal,
          unselectedIconColor: HomePalette.navInactive,
          indicatorColor: HomePalette.navActivePill,
          quality: GlassQuality.premium,
          interactionBehavior: GlassInteractionBehavior.full,
          settings: LiquidGlassSettings(
            glassColor: HomePalette.navCream.withValues(alpha: 0.8),
            thickness: 30,
            blur: 2,
            chromaticAberration: .01,
            lightAngle: GlassDefaults.lightAngle,
            lightIntensity: .5,
            ambientStrength: 0,
            refractiveIndex: 1.2,
            saturation: 1.2,
            specularSharpness: GlassSpecularSharpness.medium,
          ),
        );
      },
    );
  }
}
