import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:elevate/l10n/generated/app_localizations.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';
import '../cubit/reflection_cubit.dart';
import '../cubit/reflection_state.dart';
import '../models/reflection_spec.dart';

/// Guided reflection session shared by every [ReflectionKind]. The user names
/// three things (joys, qualities, sensations…), pauses to remember and feel
/// each one, then holds a closing feeling. The finished entry is persisted via
/// [ReflectionCubit] on the final step. All copy comes from the session's spec.
class ReflectionToolSessionScreen extends StatefulWidget {
  const ReflectionToolSessionScreen({super.key});

  @override
  State<ReflectionToolSessionScreen> createState() =>
      _ReflectionToolSessionScreenState();
}

class _ReflectionToolSessionScreenState
    extends State<ReflectionToolSessionScreen> {
  // One controller per item; text is mirrored into the cubit as the user types.
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final items = context.read<ReflectionCubit>().state.items;
    _controllers = List.generate(
      items.length,
      (i) => TextEditingController(text: items[i]),
    );
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
    final ok = await context.read<ReflectionCubit>().save();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reflectionSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spec = context.read<ReflectionCubit>().spec;
    final copy = spec.copy(l10n);
    return Scaffold(
      backgroundColor: JournalPalette.scrim,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: BlocBuilder<ReflectionCubit, ReflectionState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar: close (X) on the right.
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close,
                          size: 26.sp, color: HomePalette.titleDark),
                      onPressed: withHaptic(() => Navigator.of(context).pop()),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _stepContent(context, copy, spec, state),
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
    ReflectionCopy copy,
    ReflectionSpec spec,
    ReflectionState state,
  ) {
    switch (state.step) {
      case 0:
        return _EnterStep(copy: copy, controllers: _controllers);
      case 1:
        return _RememberStep(copy: copy, spec: spec, items: state.items);
      default:
        return _AffirmStep(copy: copy, spec: spec);
    }
  }

  /// Bottom action: "Continue" for the first two steps, "Done" (saves) for the
  /// last. On step 0 it's disabled until all three items are filled.
  Widget _primaryButton(
    BuildContext context,
    AppLocalizations l10n,
    ReflectionState state,
  ) {
    final cubit = context.read<ReflectionCubit>();
    final isLast = state.step >= 2;
    final enabled = state.step == 0 ? state.allFilled : true;

    VoidCallback? onTap;
    if (state.isSaving) {
      onTap = null;
    } else if (isLast) {
      onTap = _finish;
    } else if (enabled) {
      onTap = cubit.next;
    }

    return _ReflectionButton(
      label: isLast ? l10n.reflectionDone : l10n.reflectionContinue,
      isLoading: state.isSaving,
      onTap: onTap == null ? null : withHaptic(onTap),
    );
  }
}

/// Step 0 — name three things.
class _EnterStep extends StatelessWidget {
  final ReflectionCopy copy;
  final List<TextEditingController> controllers;

  const _EnterStep({required this.copy, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          copy.prompt,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: HomePalette.textDarkGreen,
            height: 1.25,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          copy.hint,
          style: TextStyle(fontSize: 14.sp, color: HomePalette.subtitleGrey),
        ),
        SizedBox(height: 24.h),
        for (var i = 0; i < controllers.length; i++) ...[
          _ItemField(
            controller: controllers[i],
            label: copy.itemLabel(i + 1),
            onChanged: (text) =>
                context.read<ReflectionCubit>().setItem(i, text),
          ),
          SizedBox(height: 14.h),
        ],
      ],
    );
  }
}

/// A single rounded text field for one item.
class _ItemField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  const _ItemField({
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

/// Step 1 — sit with the three items.
class _RememberStep extends StatelessWidget {
  final ReflectionCopy copy;
  final ReflectionSpec spec;
  final List<String> items;

  const _RememberStep({
    required this.copy,
    required this.spec,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          copy.rememberTitle,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: HomePalette.textDarkGreen,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          copy.rememberBody,
          style: TextStyle(
            fontSize: 15.sp,
            color: HomePalette.subtitleGrey,
            height: 1.4,
          ),
        ),
        SizedBox(height: 24.h),
        for (final item in items.where((i) => i.trim().isNotEmpty)) ...[
          _ItemChip(emoji: spec.chipEmoji, text: item.trim()),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

/// Read-only display of a captured item.
class _ItemChip extends StatelessWidget {
  final String emoji;
  final String text;

  const _ItemChip({required this.emoji, required this.text});

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
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
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

/// Step 2 — hold the closing feeling, then finish.
class _AffirmStep extends StatelessWidget {
  final ReflectionCopy copy;
  final ReflectionSpec spec;

  const _AffirmStep({required this.copy, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40.h),
        Text(spec.affirmEmoji, style: TextStyle(fontSize: 56.sp)),
        SizedBox(height: 24.h),
        Text(
          copy.affirmTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: HomePalette.textDarkGreen,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          copy.affirmBody,
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
class _ReflectionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ReflectionButton({
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
