import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/chat/screens/chat_page_screen.dart';
import '../features/home/screens/home_page_screen.dart';
import '../features/journal/screens/journal_page_screen.dart';
import 'app_nav_cubit.dart';

/// Hosts the Appy pages behind a single shared bottom nav. Tapping a tab swaps
/// the visible page; all stay alive (scroll/state preserved) via [IndexedStack].
/// Home (0), Chat (1) and Journal (2) are wired; other tabs keep showing Home.
class AppyShell extends StatelessWidget {
  const AppyShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppNavCubit(),
      child: BlocBuilder<AppNavCubit, int>(
        builder: (context, index) {
          return IndexedStack(
            // Tabs without a page (Tools, Community) fall back to Home.
            index: index <= 2 ? index : 0,
            children: const [HomePage(), ChatPage(), JournalPage()],
          );
        },
      ),
    );
  }
}
