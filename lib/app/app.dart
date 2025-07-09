import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../presentation/themes/app_theme.dart';
import '../presentation/pages/home_page.dart';

/// Main application widget.
///
/// This widget sets up the application structure, including theme,
/// localization, and state management providers.
class MemorialsApp extends StatelessWidget {
  const MemorialsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routes
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },

      // App configuration
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
    );
  }
}
