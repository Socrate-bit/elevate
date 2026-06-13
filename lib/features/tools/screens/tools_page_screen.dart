import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_glass_nav_bar.dart';
import '../cubit/tools_page_cubit.dart';
import '../cubit/tools_page_state.dart';
import '../models/tools_mock_data.dart';
import '../widgets/tool_section.dart';
import '../widgets/tools_top_bar.dart';

/// Tools page — catalogue of wellness activities grouped into sections.
/// Pure UI on mock data ([ToolsMockData]).
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ToolsPageCubit(),
      child: const _ToolsView(),
    );
  }
}

class _ToolsView extends StatelessWidget {
  const _ToolsView();

  // Scene header height and how much the sections panel pulls up over it.
  static const _headerHeight = 200.0;
  static const _panelOverlap = 28.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.grass,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 54.w,
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
        title: const SafeArea(bottom: false, child: ToolsTopBar()),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Stack(
          children: [
            // Scene behind the top of the page.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _headerHeight.h,
              child: const _SceneHeader(),
            ),
            // Translucent sections panel pulled up to overlap the scene.
            Padding(
              padding: EdgeInsets.only(top: (_headerHeight - _panelOverlap).h),
              child: const _SectionsPanel(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<ToolsPageCubit, ToolsPageState>(
        buildWhen: (p, c) => p.navIndex != c.navIndex,
        builder: (context, state) => AppGlassNavBar(
          selectedIndex: state.navIndex,
          onTabSelected: (index) {
            // Home tab returns to the previous (home) page.
            if (index == 0) {
              Navigator.of(context).maybePop();
              return;
            }
            context.read<ToolsPageCubit>().selectTab(index);
          },
        ),
      ),
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

/// Illustrated scene with Appy peeking over the hill.
class _SceneHeader extends StatelessWidget {
  const _SceneHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Sky + trees + grass from the shared scene art.
        Positioned.fill(
          child: Image.asset(
            'assets/home/background_static.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        // Appy peeking — its lower body is hidden behind the panel above.
        Image.asset(
          'assets/home/pet_rest_animation.gif',
          width: 150.w,
          height: 150.w,
          gaplessPlayback: true,
        ),
      ],
    );
  }
}

/// Rounded translucent panel holding the three tool sections.
class _SectionsPanel extends StatelessWidget {
  const _SectionsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HomePalette.toolsPanel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 100.h),
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
    );
  }
}
