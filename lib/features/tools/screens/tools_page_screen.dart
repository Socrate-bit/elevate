import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import 'package:elevate/features/shell/widgets/appy_nav_bar.dart';
import '../models/tools_mock_data.dart';
import '../widgets/tool_section.dart';
import '../widgets/tools_top_bar.dart';

/// Tools page — catalogue of wellness activities grouped into sections.
/// Pure UI on mock data ([ToolsMockData]); hosted by the shared AppyShell, so
/// the bottom nav is driven by the shell's [AppNavCubit].
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Top inset (status bar) so the scroll content clears the floating app bar.
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: JournalPalette.scrim,
      extendBody: true,
      extendBodyBehindAppBar: true,
      // Fixed, floating header (same pattern as the Journal page): stays in
      // place while the content scrolls beneath it.
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
        title: const ToolsTopBar(),
      ),
      body: Stack(
        children: [
          // Same forest scene as the Journal page, fading into a soft surface.
          const Positioned.fill(child: _ToolsBackground()),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Clear the floating app bar, then drop the panel down the scene.
                SizedBox(height: topInset + 52.h + 111.h),
                // Detached translucent panel, padded clear of the edges.
                const _SectionsPanel(),
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

/// Section header accent color, keyed by section title.
Color _accentFor(String title) {
  switch (title) {
    case 'Journaling':
      return HomePalette.toolsJournalingAmber;
    case 'Therapy':
      return HomePalette.toolsTherapyPurple;
    default:
      return HomePalette.toolsWellnessGreen;
  }
}

/// Full-bleed forest scene (shared with Journal) with a vertical scrim that
/// fades it into a readable surface behind the panel.
class _ToolsBackground extends StatelessWidget {
  const _ToolsBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.translate(
          offset: Offset(0, -100.h),
          child: Image.asset(
            'assets/journal/page_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
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

/// Detached, translucent rounded panel holding the three tool sections.
class _SectionsPanel extends StatelessWidget {
  const _SectionsPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: HomePalette.toolsPanel.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(28.r),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in ToolsMockData.sections) ...[
              ToolSectionWidget(
                section: section,
                titleColor: _accentFor(section.title),
              ),
              SizedBox(height: 18.h),
            ],
          ],
        ),
      ),
    );
  }
}
