import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import 'insight_progress_button.dart';

/// Bottom sheet explaining that insights are forming. When the ring is full it
/// switches to a "ready" state offering to reveal the insight now.
Future<void> showInsightFormingSheet(BuildContext context, ChatCubit cubit) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.of(context).background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) =>
        BlocProvider.value(value: cubit, child: const _InsightFormingSheet()),
  );
}

class _InsightFormingSheet extends StatelessWidget {
  const _InsightFormingSheet();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          final cubit = context.read<ChatCubit>();
          final ready = cubit.isInsightReady;
          final generating = state.isGeneratingInsight;

          return Padding(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Handle(),
                SizedBox(height: 18.h),
                _RingBadge(
                  progress: generating ? null : cubit.insightProgress,
                  highlight: ready,
                ),
                SizedBox(height: 22.h),
                Text(
                  ready
                      ? l10n.chatInsightsReadyTitle
                      : l10n.chatInsightsFormingTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  ready
                      ? l10n.chatInsightsReadyBody
                      : l10n.chatInsightsFormingBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.4,
                    color: c.textSecondary,
                  ),
                ),
                SizedBox(height: 28.h),
                _PrimaryButton(
                  label: ready
                      ? l10n.chatInsightsReveal
                      : l10n.chatInsightsContinue,
                  loading: generating,
                  onTap: () async {
                    if (ready) {
                      await cubit.generateInsightNow();
                      if (context.mounted) Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Large centered progress ring with the insight glyph. A null [progress]
/// renders an indeterminate spin (while generating).
class _RingBadge extends StatelessWidget {
  final double? progress;
  final bool highlight;

  const _RingBadge({required this.progress, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final size = 96.w;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: c.separator,
              valueColor: const AlwaysStoppedAnimation(ChatPalette.accent),
            ),
          ),
          Icon(
            kInsightIcon,
            size: 40.sp,
            color: highlight ? ChatPalette.accent : c.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final Future<void> Function() onTap;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: Material(
        color: ChatPalette.accent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: loading ? null : withHaptic(() => onTap()),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: c.separator,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
