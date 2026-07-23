import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../../subscription/services/analytics_service.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import 'insight_forming_sheet.dart';

/// Icon used across the insight surfaces (ring, sheet, card).
const kInsightIcon = Icons.troubleshoot_rounded;

/// Top-right chat-header button: a frosted circle with a progress ring that
/// fills as the conversation grows. When full it highlights to invite a tap;
/// tapping always opens the "insights forming" sheet.
class InsightProgressButton extends StatelessWidget {
  const InsightProgressButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, _) {
        final cubit = context.read<ChatCubit>();
        final progress = cubit.insightProgress;
        final ready = cubit.isInsightReady;
        final size = 44.w;

        return GestureDetector(
          onTap: withHaptic(() {
            AnalyticsService.capture(AnalyticsService.chatInsightsFormingOpened);
            showInsightFormingSheet(context, cubit);
          }),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ready ? ChatPalette.accent : ChatPalette.composer,
                  shape: BoxShape.circle,
                  boxShadow: ready
                      ? [
                          BoxShadow(
                            color: ChatPalette.accent.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: size,
                      height: size,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2.5,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation(
                          ready ? Colors.white : ChatPalette.accent,
                        ),
                      ),
                    ),
                    Icon(
                      kInsightIcon,
                      size: 20.sp,
                      color: ready ? Colors.white : ChatPalette.headerTitle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
