import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../features/chat/screens/chat_page_screen.dart';
import '../../features/subscription/services/analytics_service.dart';
import '../app_nav_cubit.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_utils.dart';

/// Liquid-glass bottom navigation bar (2 tabs: Home, Journal) driven by
/// [AppNavCubit], with a circular chat button perched to its right that opens
/// the chat full-page. Shared by all Appy pages.
class AppyNavBar extends StatelessWidget {
  const AppyNavBar({super.key});

  /// Opens the chat as a standalone full-page route. ChatPage's cubits are all
  /// app-global (provided in app.dart), so no extra provider wiring is needed.
  void _openChat(BuildContext context) {
    AnalyticsService.capture(AnalyticsService.chatOpened);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatPage(fullScreen: true)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      // Outer margins own the insets so the bar and the perched chat button
      // share one row (dimensions mirror the reference add-button layout).
      padding: EdgeInsets.only(bottom: 16.h, left: 24.w, right: 24.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: BlocBuilder<AppNavCubit, int>(
              builder: (context, selectedIndex) {
                return GlassBottomBar(
                  tabs: [
                    GlassBottomBarTab(
                      thickness: 1,
                      label: l10n.navHome,
                      icon: const Icon(Icons.home_rounded),
                    ),
                    GlassBottomBarTab(
                      label: l10n.navJournal,
                      icon: const Icon(Icons.menu_book_rounded),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onTabSelected: withHapticValue(
                    context.read<AppNavCubit>().selectTab,
                  )!,
                  // Outer Padding owns the margins; let the bar fill the slot.
                  horizontalPadding: 0,
                  verticalPadding: 0,
                  barHeight: 80.h,
                  iconSize: 35.sp,
                  labelFontSize: 11.sp,
                  iconLabelSpacing: 1,
                  selectedIconColor: HomePalette.checkGreen,
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
            ),
          ),
          SizedBox(width: 12.w),
          _ChatCircleButton(onTap: () => _openChat(context)),
        ],
      ),
    );
  }
}

/// Circular chat shortcut that perches to the right of the nav bar.
class _ChatCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChatCircleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withMediumHaptic(onTap),
      child: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: HomePalette.navInactive,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: HomePalette.navInactive.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.chat_rounded,
          color: HomePalette.navCream,
          size: 44.sp,
        ),
      ),
    );
  }
}
