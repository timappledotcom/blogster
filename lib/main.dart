import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/editor_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/nostr_credentials_provider.dart';
import 'providers/library_provider.dart';
import 'screens/editor_screen.dart';

void main() {
  runApp(const BlogsterApp());
}

class BlogsterApp extends StatelessWidget {
  const BlogsterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EditorProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NostrCredentialsProvider()),
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Blogster',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: const EditorScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Georgia',
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
