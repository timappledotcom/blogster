import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/editor_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/nostr_credentials_provider.dart';
import 'providers/microblog_credentials_provider.dart';
import 'providers/library_provider.dart';
import 'screens/editor_screen.dart';
import 'themes/yaru_theme.dart';

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
        ChangeNotifierProvider(
            create: (context) => MicroblogCredentialsProvider()),
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Blogster',
            theme: YaruTheme.buildLightTheme(themeProvider.accentColor),
            darkTheme: YaruTheme.buildDarkTheme(themeProvider.accentColor),
            themeMode: themeProvider.themeMode,
            home: const EditorScreen(),
          );
        },
      ),
    );
  }
}
