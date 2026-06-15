import 'package:flutter/material.dart';

/// Curated icons available for routines. Stable string keys → IconData.
/// Adding new entries is safe; renaming an existing key would invalidate
/// previously saved routines.
const Map<String, IconData> kRoutineIcons = {
  'star': Icons.star_rounded,
  'running': Icons.directions_run_rounded,
  'walking': Icons.directions_walk_rounded,
  'cycling': Icons.directions_bike_rounded,
  'water': Icons.water_drop_rounded,
  'coffee': Icons.local_cafe_rounded,
  'food': Icons.restaurant_rounded,
  'book': Icons.menu_book_rounded,
  'pencil': Icons.edit_rounded,
  'study': Icons.school_rounded,
  'meditation': Icons.self_improvement_rounded,
  'sleep': Icons.bedtime_rounded,
  'sun': Icons.wb_sunny_rounded,
  'leaf': Icons.eco_rounded,
  'gym': Icons.fitness_center_rounded,
  'yoga': Icons.accessibility_new_rounded,
  'brush': Icons.brush_rounded,
  'music': Icons.music_note_rounded,
  'paint': Icons.palette_rounded,
  'home': Icons.home_rounded,
  'cleaning': Icons.cleaning_services_rounded,
  'shower': Icons.shower_rounded,
  'tooth': Icons.face_retouching_natural_rounded,
  'pill': Icons.medication_rounded,
  'heart': Icons.favorite_rounded,
  'phone': Icons.smartphone_rounded,
  'work': Icons.work_rounded,
  'plant': Icons.local_florist_rounded,
  'pet': Icons.pets_rounded,
  'check': Icons.check_circle_rounded,
};

const String kDefaultRoutineIconKey = 'star';

IconData routineIcon(String key) =>
    kRoutineIcons[key] ?? kRoutineIcons[kDefaultRoutineIconKey]!;

/// 8 named color swatches. Saved by key on each routine; resolved at render
/// time so we can re-tune the palette without migrating data.
const Map<String, Color> kRoutineColors = {
  'orange': Color(0xFFE07B3A),
  'blue': Color(0xFF5B8DEF),
  'green': Color(0xFF3DAD6F),
  'purple': Color(0xFF7B61FF),
  'red': Color(0xFFE05C5C),
  'pink': Color(0xFFCC4DAA),
  'yellow': Color(0xFFE0B83A),
  'teal': Color(0xFF3AB3B0),
};

const String kDefaultRoutineColorKey = 'blue';

Color routineColor(String key) =>
    kRoutineColors[key] ?? kRoutineColors[kDefaultRoutineColorKey]!;
