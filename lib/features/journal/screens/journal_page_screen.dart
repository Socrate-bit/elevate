import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_glass_nav_bar.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../widgets/journal_date_pill.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/journal_header.dart';
import '../widgets/journal_input_cues.dart';
import '../widgets/journal_insight_card.dart';
import '../widgets/journal_quote_card.dart';

/// Journal page ("Appy" design) — pure UI on mock data.
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JournalCubit(),
      child: const _JournalView(),
    );
  }
}

class _JournalView extends StatelessWidget {
  const _JournalView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JournalPalette.scrim,
      extendBody: true,
      body: Stack(
        children: [
          // Forest scene at the top, fading into a soft surface for the cards.
          const Positioned.fill(child: _JournalBackground()),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  const JournalHeader(),
                  SizedBox(height: 12.h),
                  const JournalDatePill(),
                  SizedBox(height: 16.h),
                  const JournalQuoteCard(),
                  SizedBox(height: 14.h),
                  const JournalInsightCard(),
                  SizedBox(height: 18.h),
                  const JournalInputCues(),
                  SizedBox(height: 18.h),
                  const JournalEntryList(),
                  // Clear the floating bottom nav bar.
                  SizedBox(height: 90.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _JournalNavBar(),
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
        Image.asset(
          'assets/journal/page_background.png',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
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

/// Bottom navigation bar. Selecting Home returns to the previous page.
class _JournalNavBar extends StatelessWidget {
  const _JournalNavBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      buildWhen: (p, c) => p.navIndex != c.navIndex,
      builder: (context, state) {
        return AppGlassNavBar(
          selectedIndex: state.navIndex,
          onTabSelected: (index) {
            // Home tab pops back to the Home page; others are selection-only.
            if (index == 0) {
              Navigator.of(context).maybePop();
              return;
            }
            context.read<JournalCubit>().selectTab(index);
          },
        );
      },
    );
  }
}
