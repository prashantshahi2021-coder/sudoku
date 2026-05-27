import 'dart:async';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets/premium_widgets.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1450), () {
      if (!mounted) return;
      final app = AppScope.of(context);
      Navigator.pushReplacementNamed(
        context,
        app.onboarded ? HomeScreen.route : OnboardingScreen.route,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return PremiumScaffold(
      child: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: .88, end: 1).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GridyMascot(size: 128),
                const SizedBox(height: 22),
                Text('Sudoku', style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 8),
                Text(
                  'Brain training by Gridy',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: theme.primary,
                    backgroundColor: theme.card,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
