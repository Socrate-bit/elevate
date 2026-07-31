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
///
/// Returns `true` when the session ran to completion (as opposed to being
/// closed/cancelled), so callers like the chat can notify the model that the
/// mission was done. Sessions pop with `true` from their own completion path.
Future<bool> openToolSession(BuildContext context, ToolItem item) async {
  switch (item.action) {
    case ToolAction.breathing:
      final done = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => const BreathingMissionScreen(isPreview: true),
      ));
      return done ?? false;
    case ToolAction.video:
      final done = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => VideoToolSessionScreen(
          title: item.title,
          videoUrl: item.videoUrl!,
        ),
      ));
      return done ?? false;
    case ToolAction.reflection:
      final done = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReflectionCubit(item.reflectionSpec!),
          child: const ReflectionToolSessionScreen(),
        ),
      ));
      return done ?? false;
    case ToolAction.none:
      return false;
  }
}
