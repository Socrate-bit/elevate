import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/gratitude_cubit.dart';
import '../cubit/gratitude_state.dart';

/// Guided gratitude reflection. The user names three things that gave them joy,
/// pauses to remember and feel each one, then holds gratitude for them. The
/// finished entry is persisted via [GratitudeCubit] on the final step.
class GratitudeToolSessionScreen extends StatefulWidget {
  const GratitudeToolSessionScreen({super.key});

  @override
  State<GratitudeToolSessionScreen> createState() =>
      _GratitudeToolSessionScreenState();
}

class _GratitudeToolSessionScreenState
    extends State<GratitudeToolSessionScreen> {
  // One controller per joy; text is mirrored into the cubit as the user types.
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final joys = context.read<GratitudeCubit>().state.joys;
    _controllers =
        List.generate(joys.length, (i) => TextEditingController(text: joys[i]));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Final step: persist the entry, then pop on success or surface an error.
  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await context.read<GratitudeCubit>().save();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.gratitudeSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: JournalPalette.scrim,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<GratitudeCubit, GratitudeState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar: close (X) on the right.
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close, size: 26.sp,
                          color: HomePalette.titleDark),
                      onPressed: withHaptic(() => Navigator.of(context).pop()),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _stepContent(context, l10n, state),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _primaryButton(context, l10n, state),
                  SizedBox(height: 12.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Body for the current step.
  Widget _stepContent(
    BuildContext context,
    AppLocalizations l10n,
    GratitudeState state,
  ) {
    switch (state.step) {
      case 0:
        return _EnterStep(l10n: l10n, controllers: _controllers);
      case 1:
        return _RememberStep(l10n: l10n, joys: state.joys);
      default:
        return _AffirmStep(l10n: l10n);
    }
  }

  /// Bottom action: "Continue" for the first two steps, "Done" (saves) for the
  /// last. On step 0 it's disabled until all three joys are filled.
  Widget _primaryButton(
    BuildContext context,
    AppLocalizations l10n,
    GratitudeState state,
  ) {
    final cubit = context.read<GratitudeCubit>();
    final isLast = state.step >= 2;
    final enabled = state.step == 0 ? state.allJoysFilled : true;

    VoidCallback? onTap;
    if (state.isSaving) {
      onTap = null;
    } else if (isLast) {
      onTap = _finish;
    } else if (enabled) {
      onTap = cubit.next;
    }

    return _GratitudeButton(
      label: isLast ? l10n.gratitudeDone : l10n.gratitudeContinue,
      isLoading: state.isSaving,
      onTap: onTap == null ? null : withHaptic(onTap),
    );
  }
}

/// Step 0 — name three joys.
class _EnterStep extends StatelessWidget {
  final AppLocalizations l10n;
  final List<TextEditingController> controllers;

  const _EnterStep({required this.l10n, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          l10n.gratitudeStepPrompt,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: HomePalette.textDarkGreen,
            height: 1.25,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.gratitudeHint,
          style: TextStyle(fontSize: 14.sp, color: HomePalette.subtitleGrey),
        ),
        SizedBox(height: 24.h),
        for (var i = 0; i < controllers.length; i++) ...[
          _JoyField(
            controller: controllers[i],
            label: l10n.gratitudeJoyLabel(i + 1),
            onChanged: (text) =>
                context.read<GratitudeCubit>().setJoy(i, text),
          ),
          SizedBox(height: 14.h),
        ],
      ],
    );
  }
}

/// A single rounded text field for one joy.
class _JoyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  const _JoyField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomePalette.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 2,
        minLines: 1,
        textInputAction: TextInputAction.next,
        style: TextStyle(fontSize: 15.sp, color: HomePalette.titleDark),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle:
              TextStyle(fontSize: 15.sp, color: HomePalette.subtitleGrey),
        ),
      ),
    );
  }
}

/// Step 1 — sit with the three joys.
class _RememberStep extends StatelessWidget {
  final AppLocalizations l10n;
  final List<String> joys;

  const _RememberStep({required this.l10n, required this.joys});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          l10n.gratitudeRememberTitle,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: HomePalette.textDarkGreen,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          l10n.gratitudeRememberBody,
          style: TextStyle(
            fontSize: 15.sp,
            color: HomePalette.subtitleGrey,
            height: 1.4,
          ),
        ),
        SizedBox(height: 24.h),
        for (final joy in joys.where((j) => j.trim().isNotEmpty)) ...[
          _JoyChip(text: joy.trim()),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

/// Read-only display of a captured joy.
class _JoyChip extends StatelessWidget {
  final String text;

  const _JoyChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HomePalette.cardWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Text('🌿', style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: HomePalette.titleDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 2 — hold gratitude, then finish.
class _AffirmStep extends StatelessWidget {
  final AppLocalizations l10n;

  const _AffirmStep({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40.h),
        Text('🙏', style: TextStyle(fontSize: 56.sp)),
        SizedBox(height: 24.h),
        Text(
          l10n.gratitudeAffirmTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: HomePalette.textDarkGreen,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          l10n.gratitudeAffirmBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: HomePalette.subtitleGrey,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Full-width primary action button (disabled/loading aware).
class _GratitudeButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _GratitudeButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.5,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 54.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HomePalette.toolsWellnessGreen,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
