import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/app_controller.dart';
import '../../engine/retention_engine.dart';
import '../../shared/widgets/premium_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const route = '/profile';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final stats = app.stats;
    final user = app.user;
    final engine = RetentionEngine();
    final title = engine.levelTitleFor(stats.level);
    final achievements = RetentionEngine.achievements;
    return PremiumScaffold(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: [
                    const GridyMascot(size: 78),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName.isNotEmpty == true
                                ? user!.displayName
                                : 'Player Profile',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            '@${user?.username.isNotEmpty == true ? user!.username : 'sudoku_player'} - $title - Level ${stats.level}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => _editProfile(context),
                      icon: const Icon(Icons.edit_rounded),
                    ),
                  ],
                ),
                if (app.settings.premium) ...[
                  const SizedBox(height: 12),
                  PremiumCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: app.activeTheme.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Premium verified profile badge',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'XP progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(value: (stats.xp % 300) / 300),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.xp % 300}/300 XP to next level',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PremiumCard(
                        child: _Metric(
                          label: 'Streak',
                          value: '${stats.currentStreak}',
                          icon: Icons.local_fire_department_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumCard(
                        child: _Metric(
                          label: 'Freezes',
                          value: '${stats.streakFreezes}',
                          icon: Icons.ac_unit_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final achievement in achievements)
                            Chip(
                              avatar: Icon(
                                stats.achievementIds.contains(achievement.id)
                                    ? Icons.verified_rounded
                                    : Icons.lock_rounded,
                                size: 18,
                              ),
                              label: Text(achievement.title),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Friends',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Friends and leaderboard access will appear here when sync is enabled.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Add Friend'),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.friendsList.isEmpty ?? true
                            ? 'No friends added yet.'
                            : user!.friendsList.join(', '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Puzzle history',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Favorite difficulty: ${stats.favoriteDifficulty}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Total playtime: ${formatTime(stats.totalTime)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      for (final item in stats.puzzleHistory.take(5))
                        Text(
                          item.replaceAll('|', ' - '),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (stats.puzzleHistory.isEmpty)
                        Text(
                          'No completed puzzles yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const SudokuBottomNav(currentIndex: 2),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final app = AppScope.of(context);
    final name = TextEditingController(text: app.user?.displayName ?? '');
    final username = TextEditingController(text: app.user?.username ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            TextField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () =>
                  app.updateUserProfile(photoUrl: 'local://profile/gridy'),
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Use Gridy picture'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await app.updateUserProfile(
                displayName: name.text,
                username: username.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.primary),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
