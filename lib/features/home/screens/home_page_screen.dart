import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/home_page_cubit.dart';
import '../cubit/home_page_state.dart';
import '../models/home_mock_data.dart';
import '../widgets/home_action_cards.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/quest_banner.dart';
import '../widgets/todays_plan_card.dart';

/// New illustrated home page ("Appy" design) — pure UI on mock data.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomePageCubit(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _petKey = GlobalKey();
  final _stackKey = GlobalKey();

  // Pet frame width relative to screen width.
  static const _petWidthFactor = 0.45;
  // Paws line inside the square gif frame (rest below is transparent).
  static const _petArtBottomFrac = 0.806;

  // Paws y-position within the scroll content, measured after layout so the
  // background can anchor its stump under the pet.
  double? _pawsY;

  void _measurePaws() {
    final pet = _petKey.currentContext?.findRenderObject() as RenderBox?;
    final stack = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (pet == null || stack == null) return;
    final topInStack = pet.localToGlobal(Offset.zero, ancestor: stack).dy;
    final paws = topInStack + pet.size.height * _petArtBottomFrac;
    if (paws != _pawsY) setState(() => _pawsY = paws);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measurePaws();
    });
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: HomePalette.grass,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 54.w + 12.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        // Transparent over the scene at rest; a soft sky tint once content
        // scrolls under it.
        backgroundColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.scrolledUnder)
              ? HomePalette.skyFill.withValues(alpha: 0.9)
              : HomePalette.skyFill.withValues(alpha: 0.0),
        ),
        title: const HomeTopBar(),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Stack(
          key: _stackKey,
          children: [
            // Scene background fills the content; grass continues below it
            // (and the Scaffold background is grass too) so the green reaches
            // the bottom without an Expanded filler.
            Positioned.fill(child: _SceneBackground(pawsY: _pawsY)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Clears the transparent app bar floating over the scene.
                      SizedBox(height: 18.w + 18.h),
                      const _Greeting(),
                      SizedBox(height: 12.h),
                      // Pet sits in the flow: it can never overlap the headline
                      // above or the action cards below. Both dimensions are
                      // fixed (the gif is square) so the first-frame paws
                      // measurement is already final.
                      Image.asset(
                        'assets/home/pet_rest_animation.gif',
                        key: _petKey,
                        width: w * _petWidthFactor,
                        height: w * _petWidthFactor,
                        gaplessPlayback: true,
                      ),
                      SizedBox(height: 4.h),
                      const HomeActionCards(),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
                // Translucent adventure banner over the green.
                const QuestBanner(),
                SizedBox(height: 14.h),
                // White task cards on the green background.
                BlocBuilder<HomePageCubit, HomePageState>(
                  buildWhen: (p, c) => p.planItems != c.planItems,
                  builder: (context, state) =>
                      TodaysPlanCard(items: state.planItems),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _HomeNavBar(),
    );
  }
}

/// Greeting line + headline flanked by leaf decorations.
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          l10n.homePageGreeting(HomeMockData.userName),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: HomePalette.textDarkGreen,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.flip(
              flipX: true,
              child: Text('🌿', style: TextStyle(fontSize: 12.sp)),
            ),
            SizedBox(width: 6.w),
            Text(
              l10n.homePageHeadline,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: HomePalette.headlineGreen,
              ),
            ),
            SizedBox(width: 6.w),
            Text('🌿', style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ],
    );
  }
}

/// Dezoomed static scene behind the content. Positioned in function of the
/// pet: its 850px line (stump top) sits under the measured paws position.
class _SceneBackground extends StatelessWidget {
  /// Paws y-position within the scroll content; null until first measure.
  final double? pawsY;

  const _SceneBackground({this.pawsY});

  // Background zoom: drawn this much wider than the screen, centered.
  static const _bgZoom = 1.5;
  // Paws anchor line in the square 1254px background: 850px from its top.
  static const _petAnchorFrac = 820 / 1254;

  @override
  Widget build(BuildContext context) {
    if (pawsY == null) {
      return const ColoredBox(color: HomePalette.skyFill);
    }
    final w = MediaQuery.sizeOf(context).width;
    final bgWidth = w * _bgZoom;
    final bgTop = pawsY! - bgWidth * _petAnchorFrac;
    // Sky fills the top band (down to the scene image bottom); grass green
    // fills the rest, continuing the scene's floor — the task cards float on it.
    final splitY = bgTop + bgWidth;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Grass base — the lower (green) part of the page.
        const Positioned.fill(child: ColoredBox(color: HomePalette.grass)),
        // Sky band from the top down to the scene image bottom.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: splitY,
          child: const ColoredBox(color: HomePalette.skyFill),
        ),
        Positioned(
          left: (w - bgWidth) / 2,
          width: bgWidth,
          top: bgTop,
          height: bgWidth,
          child: Image.asset(
            'assets/home/background_static.png',
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
        ),
      ],
    );
  }
}

/// Liquid-glass bottom navigation bar (5 tabs, selection only).
class _HomeNavBar extends StatelessWidget {
  const _HomeNavBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<HomePageCubit, HomePageState>(
      buildWhen: (p, c) => p.navIndex != c.navIndex,
      builder: (context, state) {
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
              label: l10n.navTools,
              icon: const Icon(Icons.spa_rounded),
            ),
            GlassBottomBarTab(
              thickness: 1,
              label: l10n.navCommunity,
              icon: const Icon(Icons.people_rounded),
            ),
          ],
          selectedIndex: state.navIndex,
          onTabSelected: withHapticValue(
            context.read<HomePageCubit>().selectTab,
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
