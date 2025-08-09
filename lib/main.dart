import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/editor_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/nostr_credentials_provider.dart';
import 'providers/microblog_credentials_provider.dart';
import 'providers/library_provider.dart';
import 'screens/editor_screen.dart';
import 'themes/yaru_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: const ThemeInitializer(),
    );
  }
}

class ThemeInitializer extends StatefulWidget {
  const ThemeInitializer({super.key});

  @override
  State<ThemeInitializer> createState() => _ThemeInitializerState();
}

class _ThemeInitializerState extends State<ThemeInitializer> {
  @override
  void initState() {
    super.initState();
    // Load theme settings when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeProvider>().loadThemeSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Show loading screen until theme is loaded
        if (!themeProvider.isLoaded) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: themeProvider.accentColor.getColor(false),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Blogster...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.accentColor.getColor(false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'Blogster',
          theme: YaruTheme.buildLightTheme(themeProvider.accentColor),
          darkTheme: YaruTheme.buildDarkTheme(themeProvider.accentColor),
          themeMode: themeProvider.themeMode,
          home: const EditorScreen(),
        );
      },
    );
  }
}
