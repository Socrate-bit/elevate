import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/haptic_utils.dart';

/// Asks the user to name their new companion. Offers a "Shuffle" button that
/// cycles through cute suggestions, and a free text field to type a custom one.
class PetNameStep extends StatefulWidget {
  final String title;
  final String subtitle;
  final String hint;
  final String shuffleLabel;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const PetNameStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.shuffleLabel,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<PetNameStep> createState() => _PetNameStepState();
}

class _PetNameStepState extends State<PetNameStep> {
  // Proper names — shared across locales, no translation needed.
  static const _cuteNames = [
    'Minty',
    'Mochi',
    'Waffles',
    'Biscuit',
    'Pebble',
    'Coco',
    'Peanut',
    'Bubbles',
    'Noodle',
    'Sunny',
    'Clover',
    'Pumpkin',
    'Momo',
    'Poppy',
    'Ziggy',
  ];

  final _random = Random();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Seed with the existing value, or a random suggestion so Continue is
    // enabled immediately (like the reference design's prefilled name).
    final seed = (widget.initialValue ?? '').trim().isNotEmpty
        ? widget.initialValue!
        : _randomName();
    _controller = TextEditingController(text: seed);
    if ((widget.initialValue ?? '').trim().isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onChanged(seed));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _randomName() => _cuteNames[_random.nextInt(_cuteNames.length)];

  // Picks a fresh suggestion (never the one already shown) and syncs state.
  void _shuffle() {
    String next = _randomName();
    while (next == _controller.text.trim() && _cuteNames.length > 1) {
      next = _randomName();
    }
    _controller.text = next;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: c.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.subtitle,
            style: TextStyle(fontSize: 15.sp, color: c.textSecondary),
          ),
          SizedBox(height: 24.h),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onChanged: widget.onChanged,
            style: TextStyle(fontSize: 18.sp, color: c.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: c.textSecondary),
              filled: true,
              fillColor: c.card,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: c.separator, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: c.primary, width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
          SizedBox(height: 16.h),
          // Shuffle button: rerolls a cute suggestion into the field.
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: withHaptic(_shuffle),
              icon: Icon(Icons.shuffle_rounded, size: 20.sp),
              label: Text(
                widget.shuffleLabel,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.textPrimary,
                backgroundColor: c.card,
                side: BorderSide(color: c.separator, width: 1),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
