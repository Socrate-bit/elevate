import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/appy_nav_bar.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/journal_header.dart';
import '../widgets/journal_insight_card.dart';

/// Journal page ("Appy" design) — pure UI on mock data. Hosted by [AppyShell],
/// which provides the shared nav state; the bar swaps between sibling pages.
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Top inset (status bar) so the scroll content clears the floating app bar.
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: JournalPalette.scrim,
      extendBody: true,
      extendBodyBehindAppBar: true,
      // Fixed, floating header: "Journal" title + settings gear stay in place
      // while the content scrolls beneath, gaining a soft scrim once scrolled.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 52.h,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.scrolledUnder)
              ? JournalPalette.scrim.withValues(alpha: 0.92)
              : JournalPalette.scrim.withValues(alpha: 0.0),
        ),
        title: const JournalHeader(),
      ),
      body: Stack(
        children: [
          // Forest scene at the top, fading into a soft surface for the cards.
          const Positioned.fill(child: _JournalBackground()),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Clear the floating app bar (status bar + toolbar).
                SizedBox(height: topInset + 52.h + 8.h),
                const JournalInsightCard(),
                SizedBox(height: 18.h),
                const JournalEntryList(),
                // Clear the floating bottom nav bar.
                SizedBox(height: 90.h),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppyNavBar(),
    );
  }
}

/// Full-bleed scene background: the portrait forest image with a vertical scrim
/// that fades it into a readable surface behind the lower cards.
class _JournalBackground extends StatelessWidget {
  const _JournalBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Nudged up 50px so the scene sits a little higher behind the content.
        Transform.translate(
          offset: Offset(0, -100.h),
          child: Image.asset(
            'assets/journal/page_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        // Transparent over the top scene, opaque scrim behind the content.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                JournalPalette.scrim.withValues(alpha: 0.0),
                JournalPalette.scrim.withValues(alpha: 0.0),
                JournalPalette.scrim.withValues(alpha: 0.92),
                JournalPalette.scrim.withValues(alpha: 0.96),
              ],
              stops: const [0.0, 0.16, 0.4, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
