import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  /// Brand accent — replace per-project. Default is a neutral indigo/blue.
  static const brand = Color(0xFF4F46E5);

  /// Backwards-compat alias used by a few older callsites.
  static const orange = brand;

  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFFF5252);

  // Theme-sensitive instance properties
  final Color background;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color separator;
  final Color navBackground;
  final Color primary;
  final Color frozen;

  const AppColors._({
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.separator,
    required this.navBackground,
    required this.primary,
    required this.frozen,
  });

  static const _light = AppColors._(
    background: Color(0xFFF2F2F7),
    card: Colors.white,
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF666669),
    separator: Color(0xFFE5E5EA),
    navBackground: Colors.white,
    primary: brand,
    frozen: Color(0xFF4299E1),
  );

  static const _dark = AppColors._(
    background: Color(0xFF1C1C1E),
    card: Color(0xFF2C2C2E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8E8E93),
    separator: Color(0xFF38383A),
    navBackground: Color(0xFF1C1C1E),
    primary: brand,
    frozen: Color(0xFF4299E1),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _dark : _light;
  }
}

/// Palette for the illustrated "Appy" home page (sampled from the design).
class HomePalette {
  // Scene — grass/skyFill match the bottom/top edges of
  // background_static.png so the fills around the image blend seamlessly.
  static const sky = Color(0xFFCAE6E7);
  static const skyFill = Color(0xFFB4DFE9);
  static const grass = Color(0xFF8CAD43);

  // Text
  static const textDarkGreen = Color(0xFF0C3718);
  static const headlineGreen = Color(0xFF0C3718);
  static const titleDark = Color(0xFF3A4440);
  static const subtitleGrey = Color(0xFF8C9189);

  // Surfaces
  static const cream = Color(0xFFFCF5EC);
  static const cardWhite = Color(0xFFFFFFFC);
  static const navCream = Color(0xFFFDFBF7);

  // Accents
  static const teal = Color(0xFF1EA49A);
  static const tealDark = Color(0xFF15837C);
  static const crisisRed = Color(0xFFEC5B3A);
  static const crisisRedDark = Color(0xFFC94B2E);
  static const badgeRed = Color(0xFFF03E3E);
  static const checkGreen = Color(0xFF76A93F);
  static const incompleteOrange = Color(0xFFFA8C2C);
  static const progressYellow = Color(0xFFFEB114);
  static const progressBrown = Color(0xFFA05B23);

  // Today's plan row icon tiles
  static const tileYellow = Color(0xFFFCE6B7);
  static const tileBlue = Color(0xFFD4E8FA);
  static const tileGreen = Color(0xFFEAF0CE);
  static const timeline = Color(0xFFC9CDB4);

  // Edit pill
  static const editPillBg = Color(0xFFF0F2CF);
  static const editGreen = Color(0xFF4F7A28);

  // Task card check button (Finch-style grey rounded square)
  static const checkButtonBg = Color(0xFFEDEDE6);
  static const checkButtonBorder = Color(0xFFDDDDD4);

  // Bottom nav
  static const navActivePill = Color(0xFFD7ECE6);
  static const navInactive = Color(0xFF525A59);
}

/// Palette for the illustrated "Appy" chat page ("Forest Friend") — sampled
/// from the design. Translucent surfaces float over the cozy-room background.
class ChatPalette {
  // Appy (assistant) bubble — near-opaque white.
  static const appyBubble = Color(0xF2FFFFFF);
  static const appyText = Color(0xFF3A4440);

  // User bubble — soft translucent sage green.
  static const userBubble = Color(0xE6A8C677);
  static const userText = Color(0xFF2C3D18);
  static const timestamp = Color(0xFF5E6A52);

  // Header / "Today" — frosted dark pills with white content.
  static const glassPill = Color(0x40000000);
  static const headerTitle = Color(0xFF2C3D18);
  static const headerSubtitle = Color(0xFF5E6A52);

  // "Start a conversation" frosted panel.
  static const panel = Color(0x59343C28);
  static const panelText = Colors.white;
  static const suggestion = Color(0xF2FFFFFF);
  static const suggestionText = Color(0xFF3A4440);

  // Composer bar.
  static const composer = Color(0xF2FFFFFF);
  static const composerHint = Color(0xFF9AA08F);
  static const composerText = Color(0xFF3A4440);

  // Round action buttons (composer +, send/call) — leafy green.
  static const accent = Color(0xFF7BAE3F);
}

/// Palette for the illustrated Journal page (sampled from the design).
class JournalPalette {
  // Soft scrim that fades the scene background into a readable surface for the
  // lower cards.
  static const scrim = Color(0xFFFCF5EC);

  // Quote card — translucent sky-blue with a teal quote glyph.
  static const quoteCardBg = Color(0xFFCDE8F0);
  static const quoteGlyph = Color(0xFF6FB8C4);

  // Monthly Insight card.
  static const insightCardBg = Color(0xFFFBF6EA);
  static const insightBody = Color(0xFF5C6B57);

  // Entry icon tiles (pastel circles behind the emoji).
  static const tilePink = Color(0xFFFBE0E3);
  static const tileAmber = Color(0xFFFCEFC9);

  // Category chips (background + text) per entry type.
  static const chipConversationBg = Color(0xFFDDEBFB);
  static const chipConversationText = Color(0xFF4C7BB8);
  static const chipReflectionBg = Color(0xFFEAE2F7);
  static const chipReflectionText = Color(0xFF8266B0);
  static const chipWinBg = Color(0xFFFBEFCB);
  static const chipWinText = Color(0xFFB98417);
  static const chipPatternBg = Color(0xFFE6F0CF);
  static const chipPatternText = Color(0xFF6B8C2F);

  // Insight tag chips.
  static const tagBg = Color(0xFFEFF1DE);
  static const tagText = Color(0xFF5C6B57);
}

class AppTheme {
  static ThemeData get light {
    const bg = Color(0xFFF2F2F7);
    const card = Colors.white;
    const textPrimary = Color(0xFF1C1C1E);
    const textSecondary = Color(0xFF8E8E93);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        brightness: Brightness.light,
        surface: bg,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(fontSize: 15.sp, color: textPrimary),
        bodySmall: TextStyle(fontSize: 13.sp, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 54.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const darkBg = Color(0xFF1C1C1E);
    const darkCard = Color(0xFF2C2C2E);
    const darkText = Color(0xFFFFFFFF);
    const darkSecondary = Color(0xFF8E8E93);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brand,
        brightness: Brightness.dark,
        surface: darkBg,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.r)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: darkText,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyMedium: TextStyle(fontSize: 15.sp, color: darkText),
        bodySmall: TextStyle(fontSize: 13.sp, color: darkSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkText,
          foregroundColor: darkBg,
          minimumSize: Size(double.infinity, 54.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
