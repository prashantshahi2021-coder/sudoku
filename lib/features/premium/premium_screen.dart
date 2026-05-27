import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/widgets/premium_widgets.dart';
import '../legal/legal_screen.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});
  static const route = '/premium';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final active = app.settings.premium;
    return PremiumScaffold(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Center(child: GridyMascot(size: 96)),
                const SizedBox(height: 12),
                Text(
                  'Sudoku Premium',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'A calmer, deeper brain-training experience with fewer limits and more polish.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _PlanCard(
                  title: 'Monthly',
                  price: '\$3.99',
                  note: 'Flexible brain training',
                  selected: false,
                ),
                const SizedBox(height: 12),
                _PlanCard(
                  title: 'Yearly',
                  price: '\$24.99',
                  note: 'Best Value',
                  selected: true,
                ),
                const SizedBox(height: 12),
                _PlanCard(
                  title: 'Lifetime',
                  price: 'Later',
                  note: 'Optional one-time plan',
                  selected: false,
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium includes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      for (final item in _benefits)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: app.activeTheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(item)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Free vs Premium',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const _CompareRow(
                        label: 'Ads',
                        free: 'Yes',
                        premium: 'No',
                      ),
                      const _CompareRow(
                        label: 'Hints',
                        free: 'Limited',
                        premium: 'Unlimited',
                      ),
                      const _CompareRow(
                        label: 'Themes',
                        free: 'Core',
                        premium: 'Exclusive',
                      ),
                      const _CompareRow(
                        label: 'Cloud sync',
                        free: 'Soon',
                        premium: 'Soon',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, LegalScreen.termsRoute),
                      child: const Text('Terms'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        LegalScreen.privacyRoute,
                      ),
                      child: const Text('Privacy'),
                    ),
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Restore purchases will be available with Play Billing.',
                          ),
                        ),
                      ),
                      child: const Text('Restore purchase'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: PillButton(
              label: active ? 'Premium Active' : 'Start Premium Preview',
              icon: Icons.workspace_premium_rounded,
              onPressed: () =>
                  app.updateSettings(app.settings.copyWith(premium: true)),
            ),
          ),
        ],
      ),
    );
  }

  static const _benefits = [
    'Remove all ads',
    'Unlimited hints and smart coach',
    'Premium themes and Gridy skins',
    'Advanced statistics',
    'Unlimited bot race mode',
    'Cloud sync coming soon',
    'Daily premium challenge',
    'Premium verified profile badge',
    'Friend leaderboard coming soon',
    'Early access themes',
  ];
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.note,
    required this.selected,
  });
  final String title;
  final String price;
  final String note;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return PremiumCard(
      color: selected ? theme.primary : theme.card,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : theme.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(
                    color: selected ? Colors.white70 : theme.locked,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: selected ? Colors.white : theme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.free,
    required this.premium,
  });
  final String label;
  final String free;
  final String premium;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(width: 70, child: Text(free, textAlign: TextAlign.center)),
          SizedBox(
            width: 86,
            child: Text(
              premium,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
