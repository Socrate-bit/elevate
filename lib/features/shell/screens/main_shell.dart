import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../community/screens/community_page_screen.dart';
import '../../home/screens/home_page_screen.dart';
import '../cubit/main_shell_cubit.dart';
import '../cubit/main_shell_state.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Root shell: a single bottom nav bar that swaps between the Home and
/// Community pages (kept alive via IndexedStack so their state is preserved).
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MainShellCubit(),
      child: const _ShellView(),
    );
  }
}

class _ShellView extends StatelessWidget {
  const _ShellView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: BlocBuilder<MainShellCubit, MainShellState>(
        buildWhen: (p, c) => p.pageIndex != c.pageIndex,
        builder: (context, state) => IndexedStack(
          index: state.pageIndex,
          children: const [HomePage(), CommunityPage()],
        ),
      ),
      bottomNavigationBar: BlocBuilder<MainShellCubit, MainShellState>(
        buildWhen: (p, c) => p.selectedTab != c.selectedTab,
        builder: (context, state) => AppBottomNavBar(
          selectedIndex: state.selectedTab,
          onTabSelected: context.read<MainShellCubit>().selectTab,
        ),
      ),
    );
  }
}
