import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/app_controller.dart';
import '../../data/models.dart';
import '../../engine/retention_engine.dart';
import '../../shared/widgets/ad_widgets.dart';
import '../../shared/widgets/premium_widgets.dart';
import '../game/game_screen.dart';
import '../race/race_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/statistics_screen.dart';
import '../themes/theme_selection_screen.dart';
import 'difficulty_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _rewardChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rewardChecked) return;
    _rewardChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final reward = await AppScope.of(context).claimDailyReward();
      if (!mounted || !reward.claimed) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Daily reward'),
          content: Text(
            '${reward.message}\n+${reward.xp} XP  +${reward.coins} coins',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nice'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.activeTheme;
    final stats = app.stats;
    return PremiumScaffold(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Sudoku',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            'Sudoku focus training',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () =>
                          Navigator.pushNamed(context, SettingsScreen.route),
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: theme.primary,
                  child: Row(
                    children: [
                      const GridyMascot(size: 62),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${stats.level}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${stats.currentStreak} day streak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: (stats.xp % 300) / 300,
                              color: theme.accent,
                              backgroundColor: Colors.white24,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${stats.coins}c',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  child: Row(
                    children: [
                      _StreakFlame(color: theme.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mind on fire!',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Next daily reset in ${_countdownText()}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${stats.streakFreezes} freezes',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (app.currentGame != null)
                  PremiumCard(
                    onTap: () => Navigator.pushNamed(context, GameScreen.route),
                    child: Row(
                      children: [
                        Icon(
                          Icons.replay_circle_filled_rounded,
                          color: theme.primary,
                          size: 36,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Continue ${app.currentGame!.difficulty.label} game',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          formatTime(app.currentGame!.seconds),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                PremiumCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_rounded,
                        color: theme.accent,
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Challenge',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'A fresh puzzle for coins and streak XP.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: () => _daily(context),
                        child: const Text('Play'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: PremiumCard(
                        onTap: () => _start(
                          context,
                          Difficulty.easy,
                          mode: GameMode.relax,
                        ),
                        child: _MiniMetric(
                          icon: Icons.spa_rounded,
                          label: 'Relax Mode',
                          value: 'Calm',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumCard(
                        onTap: () =>
                            Navigator.pushNamed(context, RaceScreen.route),
                        child: _MiniMetric(
                          icon: Icons.speed_rounded,
                          label: 'Speed Challenge',
                          value: 'Race',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SectionTitle(
                  'Choose difficulty',
                  action: 'All',
                  onAction: () =>
                      Navigator.pushNamed(context, DifficultyScreen.route),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: Difficulty.values
                      .map((d) => _DifficultyTile(difficulty: d))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: PremiumCard(
                        onTap: () => Navigator.pushNamed(
                          context,
                          StatisticsScreen.route,
                        ),
                        child: _MiniMetric(
                          icon: Icons.emoji_events_rounded,
                          label: 'Wins',
                          value: '${stats.gamesWon}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumCard(
                        onTap: () => Navigator.pushNamed(
                          context,
                          ThemeSelectionScreen.route,
                        ),
                        child: _MiniMetric(
                          icon: Icons.palette_rounded,
                          label: 'Theme',
                          value: theme.name.split(' ').first,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const PremiumBannerAdSlot(),
          const SizedBox(height: 8),
          const SudokuBottomNav(currentIndex: 0),
        ],
      ),
    );
  }

  static Future<void> _start(
    BuildContext context,
    Difficulty difficulty, {
    GameMode mode = GameMode.classic,
  }) async {
    await AppScope.of(context).startGame(difficulty, mode: mode);
    if (context.mounted) Navigator.pushNamed(context, GameScreen.route);
  }

  static Future<void> _daily(BuildContext context) async {
    await AppScope.of(context).startDailyChallenge();
    if (context.mounted) Navigator.pushNamed(context, GameScreen.route);
  }

  String _countdownText() {
    final duration = RetentionEngine().dailyCountdown(DateTime.now());
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({required this.difficulty});
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _HomeScreenState._start(context, difficulty),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.grid_4x4_rounded, color: theme.primary),
          Text(
            difficulty.label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
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
      children: [
        Icon(icon, color: theme.primary),
        const SizedBox(height: 10),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _StreakFlame extends StatelessWidget {
  const _StreakFlame({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .92, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, value, child) => Transform.scale(scale: value, child: child),
      child: Icon(Icons.local_fire_department_rounded, color: color, size: 36),
    );
  }
}
