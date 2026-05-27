import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/app_controller.dart';
import 'features/complete/level_complete_screen.dart';
import 'features/game/game_screen.dart';
import 'features/home/difficulty_screen.dart';
import 'features/home/home_screen.dart';
import 'features/legal/legal_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/premium/premium_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/race/race_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/stats/statistics_screen.dart';
import 'features/themes/theme_selection_screen.dart';
import 'shared/services/app_feedback.dart';

class SudokuApp extends StatefulWidget {
  const SudokuApp({super.key});

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  late final AppController controller;
  final lifecycleObserver = _AmbientLifecycleObserver();

  @override
  void initState() {
    super.initState();
    controller = AppController()..load();
    WidgetsBinding.instance.addObserver(lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(lifecycleObserver);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final theme = SudokuTheme.catalog[controller.themeId]!;
          final themeData = _scaledTheme(
            theme.toThemeData(),
            controller.settings.largeNumbers,
          );
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Sudoku',
            theme: themeData,
            initialRoute: SplashScreen.route,
            routes: {
              SplashScreen.route: (_) => const SplashScreen(),
              OnboardingScreen.route: (_) => const OnboardingScreen(),
              PremiumScreen.route: (_) => const PremiumScreen(),
              HomeScreen.route: (_) => const HomeScreen(),
              DifficultyScreen.route: (_) => const DifficultyScreen(),
              GameScreen.route: (_) => const GameScreen(),
              LegalScreen.privacyRoute: (_) => const LegalScreen.privacy(),
              LegalScreen.termsRoute: (_) => const LegalScreen.terms(),
              LevelCompleteScreen.route: (_) => const LevelCompleteScreen(),
              StatisticsScreen.route: (_) => const StatisticsScreen(),
              ProfileScreen.route: (_) => const ProfileScreen(),
              RaceScreen.route: (_) => const RaceScreen(),
              ThemeSelectionScreen.route: (_) => const ThemeSelectionScreen(),
              SettingsScreen.route: (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

ThemeData _scaledTheme(ThemeData theme, bool largeText) {
  if (!largeText) return theme;
  TextStyle? scale(TextStyle? style, double delta) {
    if (style == null) return null;
    return style.copyWith(fontSize: (style.fontSize ?? 14) + delta);
  }

  final text = theme.textTheme;
  return theme.copyWith(
    textTheme: text.copyWith(
      bodySmall: scale(text.bodySmall, 1),
      bodyMedium: scale(text.bodyMedium, 2),
      bodyLarge: scale(text.bodyLarge, 2),
      labelSmall: scale(text.labelSmall, 1),
      labelMedium: scale(text.labelMedium, 2),
      labelLarge: scale(text.labelLarge, 2),
      titleSmall: scale(text.titleSmall, 1),
      titleMedium: scale(text.titleMedium, 2),
      titleLarge: scale(text.titleLarge, 2),
    ),
  );
}

class _AmbientLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AppFeedback.resumeAmbient();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        AppFeedback.pauseAmbient();
    }
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.notifier!;
  }
}
