import 'package:flutter/material.dart';

import '../../app.dart';
import '../../features/home/home_screen.dart';
import '../../shared/widgets/premium_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const route = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  int step = 0;
  String photoUrl = '';

  @override
  void dispose() {
    controller.dispose();
    nameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) => setState(() => step = value),
              children: [
                _Welcome(onNext: _next),
                _InputStep(
                  title: 'What should Gridy call you?',
                  hint: 'Display name',
                  controller: nameController,
                  icon: Icons.badge_rounded,
                ),
                _InputStep(
                  title: 'Choose a username',
                  hint: 'username',
                  controller: usernameController,
                  icon: Icons.alternate_email_rounded,
                ),
                _GoogleStep(onSignIn: _signIn),
                _PhotoStep(
                  photoUrl: photoUrl,
                  onPick: () =>
                      setState(() => photoUrl = 'local://profile/gridy'),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(
              5,
              (index) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index <= step
                        ? AppScope.of(context).activeTheme.primary
                        : AppScope.of(context).activeTheme.boardLine,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (step != 0 && step != 3)
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: step == 4 ? 'Go Home' : 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: step == 4 ? _finish : _next,
              ),
            ),
        ],
      ),
    );
  }

  void _next() {
    controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _signIn() async {
    await AppScope.of(context).signInWithGoogle(
      displayName: nameController.text,
      username: usernameController.text,
    );
    _next();
  }

  Future<void> _finish() async {
    if (photoUrl.isNotEmpty) {
      await AppScope.of(context).updateUserProfile(photoUrl: photoUrl);
    }
    if (mounted) Navigator.pushReplacementNamed(context, HomeScreen.route);
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return Column(
      children: [
        const Spacer(),
        const GridyMascot(size: 132),
        const SizedBox(height: 28),
        Text('Sudoku', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text(
          'Train focus with beautiful puzzles, streaks, smart hints, and premium themes.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        PremiumCard(
          color: theme.card.withValues(alpha: .92),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: theme.accent),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Gridy helps when logic gets foggy, but keeps the win yours.',
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            label: 'Start',
            icon: Icons.play_arrow_rounded,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}

class _InputStep extends StatelessWidget {
  const _InputStep({
    required this.title,
    required this.hint,
    required this.controller,
    required this.icon,
  });
  final String title;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 72),
        GridyMascot(size: 86),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        PremiumCard(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              hintText: hint,
              border: InputBorder.none,
            ),
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}

class _GoogleStep extends StatelessWidget {
  const _GoogleStep({required this.onSignIn});
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const GridyMascot(size: 104),
        const SizedBox(height: 24),
        Text(
          'Continue with Google',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Google sign-in is prepared. This closed-testing build safely creates a local profile.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            label: 'Continue with Google',
            icon: Icons.g_mobiledata_rounded,
            onPressed: onSignIn,
          ),
        ),
      ],
    );
  }
}

class _PhotoStep extends StatelessWidget {
  const _PhotoStep({required this.photoUrl, required this.onPick});
  final String photoUrl;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        GridyMascot(size: photoUrl.isEmpty ? 104 : 118),
        const SizedBox(height: 24),
        Text(
          'Add a profile photo?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Optional for now. You can update it anytime from your profile.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        PillButton(
          label: photoUrl.isEmpty ? 'Use Gridy Avatar' : 'Avatar selected',
          icon: Icons.add_a_photo_rounded,
          onPressed: onPick,
        ),
        const Spacer(),
      ],
    );
  }
}
