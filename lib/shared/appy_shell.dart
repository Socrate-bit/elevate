import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/home/screens/home_page_screen.dart';
import '../features/journal/screens/journal_page_screen.dart';
import '../features/quest/screens/quest_page_screen.dart';
import 'app_nav_cubit.dart';

/// Hosts the Appy pages behind a single shared bottom nav. Tapping a tab swaps
/// the visible page; all stay alive (scroll/state preserved) via [IndexedStack].
/// Home (0), Quest (1) and Journal (2) are wired; Chat opens full-page from the
/// nav bar's side button.
class AppyShell extends StatelessWidget {
  const AppyShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppNavCubit(),
      child: BlocBuilder<AppNavCubit, int>(
        builder: (context, index) {
          return IndexedStack(
            index: index,
            children: const [
              HomePage(),
              QuestPage(),
              JournalPage(),
            ],
          );
        },
      ),
    );
  }
}
