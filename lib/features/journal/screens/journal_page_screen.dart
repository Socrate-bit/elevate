import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../navigation/appy_nav_bar.dart';
import '../../trophy/cubit/trophies_cubit.dart';
import '../cubit/journal_cubit.dart';
import '../widgets/journal_header.dart';
import '../widgets/journal_insight_list.dart';
import '../widgets/journal_summary_cards.dart';

/// Journal page ("Appy" design) — a full-bleed forest scene behind two summary
/// tiles (insights + wisdom counts) and the scrollable list of generated
/// insights wrapped in a translucent panel. Hosted by [AppyShell], which
/// provides the shared nav state; the bar swaps between sibling pages.
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => JournalCubit()..start()),
        BlocProvider(create: (_) => TrophiesCubit()..start()),
      ],
      child: const _JournalView(),
    );
  }
}

class _JournalView extends StatelessWidget {
  const _JournalView();

  @override
  Widget build(BuildContext context) {
    // Top inset (status bar) so the scroll content clears the floating app bar.
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      // Scene-matching backdrop so the strip behind the floating nav bar (and
      // any inset the cover image doesn't reach) blends with the grass instead
      // of the default grey — mirrors the home page.
      backgroundColor: HomePalette.grass,
      
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      // Fixed, floating header: the white "Journal" title + trophies shortcut
      // stay in place while the content scrolls beneath the transparent bar.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 52.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: const JournalHeader(),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen forest scene behind everything.
          const Positioned.fill(child: _JournalBackground()),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  // Clear the floating app bar (status bar + toolbar).
                  SizedBox(height: topInset + 52.h + 8.h),
                  const JournalSummaryCards(),
                  SizedBox(height: 16.h),
                  // Insight list inside a big white panel over the scene.
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: HomePalette.cardWhite,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const JournalInsightList(),
                  ),
                  // Clear the floating bottom nav bar.
                  SizedBox(height: 90.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppyNavBar(),
    );
  }
}

/// Full-bleed scene background: the portrait forest image covering the whole
/// screen, with a soft top/bottom scrim so the white title and cards stay
/// legible over the illustration.
class _JournalBackground extends StatelessWidget {
  const _JournalBackground();

  @override
  Widget build(BuildContext context) {
    // The scene fills the whole box via a DecorationImage (cover) — the most
    // reliable full-bleed pattern — with a soft top/bottom scrim on top for
    // title/nav legibility.
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/journal/page_background.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.28),
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.0),
              Colors.black.withValues(alpha: 0.22),
            ],
            stops: const [0.0, 0.2, 0.62, 1.0],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
