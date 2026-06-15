import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../chat/screens/chat_page_screen.dart';
import '../community/screens/community_page_screen.dart';
import '../home/screens/home_page_screen.dart';
import '../journal/screens/journal_page_screen.dart';
import '../tools/screens/tools_page_screen.dart';
import 'app_nav_cubit.dart';

/// Hosts the Appy pages behind a single shared bottom nav. Tapping a tab swaps
/// the visible page; all stay alive (scroll/state preserved) via [IndexedStack].
/// Home (0), Chat (1), Journal (2), Tools (3) and Community (4) are wired.
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
              ChatPage(),
              JournalPage(),
              ToolsPage(),
              CommunityPage(),
            ],
          );
        },
      ),
    );
  }
}
