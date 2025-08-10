import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class YaruTheme {
  // Ubuntu brand colors
  static const Color ubuntuOrange = Color(0xFFE95420);
  static const Color ubuntuPurple = Color(0xFF772953);
  static const Color ubuntuAubergine = Color(0xFF77216F);
  static const Color ubuntuCanonicalAubergine = Color(0xFF2C001E);

  // Ubuntu light theme with dynamic accent color
  static ThemeData buildLightTheme(UbuntuAccentColor accentColor) {
    final primaryColor = accentColor.lightColor;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryColor,
      secondary: ubuntuPurple,
      tertiary: ubuntuAubergine,
      surface: Colors.white,
      onSurface: const Color(0xFF1D1D1D),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Ubuntu font stack
      textTheme: _buildTextTheme(ThemeData.light().textTheme, false),

      // Ubuntu-style app bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1D1D1D),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Color(0xFF1D1D1D),
        ),
      ),

      // Yaru-style cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Ubuntu-style buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: TextStyle(
          fontFamily: 'Ubuntu',
          color: Colors.grey.shade600,
        ),
      ),

      // Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryColor.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Color(0xFF1D1D1D),
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Ubuntu',
          fontSize: 14,
          color: Color(0xFF1D1D1D),
        ),
      ),
    );
  }

  // Ubuntu dark theme with dynamic accent color
  static ThemeData buildDarkTheme(UbuntuAccentColor accentColor) {
    final primaryColor = accentColor.darkColor;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryColor,
      secondary: ubuntuPurple,
      tertiary: ubuntuAubergine,
      surface: const Color(0xFF2D2D2D),
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Ubuntu font stack
      textTheme: _buildTextTheme(ThemeData.dark().textTheme, true),

      // Ubuntu-style app bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Colors.white,
        ),
      ),

      // Yaru-style cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF2D2D2D),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Colors.grey.shade700,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Ubuntu-style buttons (dark)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input decoration (dark)
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: TextStyle(
          fontFamily: 'Ubuntu',
          color: Colors.grey.shade400,
        ),
      ),

      // Navigation (dark)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryColor.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: 'Ubuntu', fontWeight: FontWeight.w500),
        ),
      ),

      // Dialog theme (dark)
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Colors.white,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Ubuntu',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  // Ubuntu font hierarchy
  static TextTheme _buildTextTheme(TextTheme base, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1D1D1D);

    return base.copyWith(
      // Display styles - Ubuntu font for headings
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w300,
        color: textColor,
        letterSpacing: -0.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w300,
        color: textColor,
        letterSpacing: -0.5,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        color: textColor,
      ),

      // Headlines - Ubuntu font
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Titles - Ubuntu font
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: -0.2,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Body text - Ubuntu Mono for code, Ubuntu for regular text
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.6,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w400,
        color: textColor,
      ),

      // Labels - Ubuntu font
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontFamily: 'Ubuntu',
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
