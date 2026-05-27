import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/app_controller.dart';
import '../../shared/widgets/ad_widgets.dart';
import '../../shared/widgets/premium_widgets.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});
  static const route = '/stats';

  @override
  Widget build(BuildContext context) {
    final stats = AppScope.of(context).stats;
    final items = [
      (Icons.emoji_events_rounded, 'Games won', '${stats.gamesWon}'),
      (Icons.stars_rounded, 'Best score', '${stats.bestScore}'),
      (Icons.timer_rounded, 'Best time', formatTime(stats.bestTime)),
      (Icons.av_timer_rounded, 'Average time', formatTime(stats.averageTime)),
      (Icons.verified_rounded, 'No-mistake wins', '${stats.noMistakeWins}'),
      (
        Icons.local_fire_department_rounded,
        'Current streak',
        '${stats.currentStreak}',
      ),
      (Icons.military_tech_rounded, 'Longest streak', '${stats.longestStreak}'),
    ];
    return PremiumScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text('Statistics', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: items
                  .map(
                    (item) => PremiumCard(
                      child: _StatCard(
                        icon: item.$1,
                        label: item.$2,
                        value: item.$3,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          const PremiumBannerAdSlot(),
          const SizedBox(height: 8),
          const SudokuBottomNav(currentIndex: 1),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: theme.primary, size: 32),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
