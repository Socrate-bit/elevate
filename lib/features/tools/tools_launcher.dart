import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../missions/screens/breathing_mission_screen.dart';
import 'cubit/reflection_cubit.dart';
import 'models/tools_mock_data.dart';
import 'screens/reflection_tool_session_screen.dart';
import 'screens/video_tool_session_screen.dart';

/// Opens a tool's guided session (breathing, guided video, or reflection).
/// [ToolAction.none] tools have no session and are a no-op. Shared by the tools
/// selector, the today's-plan tool tasks, and the chat mission suggestion card.
void openToolSession(BuildContext context, ToolItem item) {
  switch (item.action) {
    case ToolAction.breathing:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const BreathingMissionScreen(isPreview: true),
      ));
    case ToolAction.video:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => VideoToolSessionScreen(
          title: item.title,
          videoUrl: item.videoUrl!,
        ),
      ));
    case ToolAction.reflection:
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReflectionCubit(item.reflectionSpec!),
          child: const ReflectionToolSessionScreen(),
        ),
      ));
    case ToolAction.none:
      break;
  }
}
