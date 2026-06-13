import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/chat/screens/chat_page_screen.dart';
import '../features/home/screens/home_page_screen.dart';
import 'app_nav_cubit.dart';

/// Hosts the Appy pages behind a single shared bottom nav. Tapping a tab swaps
/// the visible page; both stay alive (scroll/state preserved) via [IndexedStack].
/// Only Home (0) and Chat (1) are wired; other tabs keep showing Home.
class AppyShell extends StatelessWidget {
  const AppyShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppNavCubit(),
      child: BlocBuilder<AppNavCubit, int>(
        builder: (context, index) {
          return IndexedStack(
            // Tabs without a page fall back to Home.
            index: index == 1 ? 1 : 0,
            children: const [HomePage(), ChatPage()],
          );
        },
      ),
    );
  }
}
