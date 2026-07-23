import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../../shared/widgets/appy_nav_bar.dart';
import '../models/tools_mock_data.dart';
import '../widgets/tool_section.dart';
import '../widgets/tools_top_bar.dart';

/// Tools page — catalogue of wellness activities grouped into sections.
/// Pure UI on mock data ([ToolsMockData]).
class ToolsPage extends StatelessWidget {
  /// When true, the page is shown as a standalone pushed route: the bottom nav
  /// bar is hidden and a back button is overlaid to pop back (e.g. opened from
  /// the chat top bar). Otherwise it's hosted by the shared AppyShell.
  final bool fullScreen;

  const ToolsPage({super.key, this.fullScreen = false});

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
        leading: fullScreen
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: HomePalette.textDarkGreen,
                  size: 20.sp,
                ),
                onPressed: withHaptic(() => Navigator.of(context).maybePop()),
              )
            : null,
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
                // Clear the floating bottom nav bar (or just the edge when
                // shown as a standalone page without the nav bar).
                SizedBox(height: fullScreen ? 24.h : 90.h),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: fullScreen ? null : const AppyNavBar(),
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
