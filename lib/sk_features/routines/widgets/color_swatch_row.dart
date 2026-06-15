import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/utils/haptic_utils.dart';
import '../models/routine_palette.dart';

/// Horizontal row of color swatches. Tapping a swatch selects it.
class ColorSwatchRow extends StatelessWidget {
  final String selectedKey;
  final ValueChanged<String> onChanged;

  const ColorSwatchRow({
    super.key,
    required this.selectedKey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final entries = kRoutineColors.entries.toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: entries.map((entry) {
        final selected = entry.key == selectedKey;
        return GestureDetector(
          onTap: withHaptic(() => onChanged(entry.key)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: entry.value,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: entry.value.withAlpha(120),
                    blurRadius: 10,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
