import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/app_controller.dart';
import '../../data/models.dart';
import '../../engine/retention_engine.dart';
import '../../shared/services/app_feedback.dart';
import '../../shared/widgets/premium_widgets.dart';
import '../game/game_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../stats/statistics_screen.dart';
import '../themes/theme_selection_screen.dart';

class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({super.key});
  static const route = '/complete';

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController confetti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void initState() {
    super.initState();
    AppFeedback.haptic(HapticKind.success);
    AppFeedback.sound(AppSound.win);
  }

  @override
  void dispose() {
    confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final result = app.lastResult ?? _previewResult(app);
    final theme = app.activeTheme;
    return PremiumScaffold(
      child: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 14),
              const Center(child: GridyMascot(mood: 'win', size: 104)),
              const SizedBox(height: 12),
              ScaleTransition(
                scale: Tween<double>(begin: .88, end: 1).animate(
                  CurvedAnimation(parent: confetti, curve: Curves.elasticOut),
                ),
                child: Text(
                  'Hooray!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              Text(
                _victoryMessage(result),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              PremiumCard(
                color: Color.lerp(theme.card, theme.accent, .08),
                child: Column(
                  children: [
                    _PreviewBoard(board: result.board),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Reward(
                          label: 'XP',
                          value: '+${result.xp}',
                          icon: Icons.bolt_rounded,
                        ),
                        _Reward(
                          label: 'Coins',
                          value: '+${result.coins}',
                          icon: Icons.toll_rounded,
                        ),
                        _Reward(
                          label: 'Accuracy',
                          value: '${result.accuracy}%',
                          icon: Icons.check_circle_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (result.dailyChallenge || app.stats.currentStreak > 0)
                PremiumCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: theme.warning,
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${app.stats.currentStreak} Day Streak',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        'Mind on fire!',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: PremiumCard(
                      child: _Reward(
                        label: 'Time',
                        value: formatTime(result.seconds),
                        icon: Icons.timer_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PremiumCard(
                      child: _Reward(
                        label: 'Level',
                        value: result.levelTitle,
                        icon: Icons.workspace_premium_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (app.latestAchievements.isNotEmpty)
                PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievement unlocked',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      for (final achievement in app.latestAchievements.take(3))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.workspace_premium_rounded,
                            color: theme.accent,
                          ),
                          title: Text(achievement.title),
                          subtitle: Text(achievement.description),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              PillButton(
                label: 'New Game',
                icon: Icons.play_arrow_rounded,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, HomeScreen.route),
              ),
              const SizedBox(height: 10),
              PillButton(
                label: 'Next Difficulty',
                icon: Icons.trending_up_rounded,
                onPressed: () async {
                  final next =
                      Difficulty.values[(result.difficulty.index + 1).clamp(
                        0,
                        Difficulty.values.length - 1,
                      )];
                  await app.startGame(next);
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, GameScreen.route);
                  }
                },
              ),
              const SizedBox(height: 10),
              PillButton(
                label: 'Share Result',
                icon: Icons.ios_share_rounded,
                filled: false,
                onPressed: () => _shareDialog(context, result),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SudokuIconTile(
                      icon: Icons.bar_chart_rounded,
                      label: 'Stats',
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        StatisticsScreen.route,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SudokuIconTile(
                      icon: Icons.palette_rounded,
                      label: 'Theme',
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        ThemeSelectionScreen.route,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SudokuIconTile(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        SettingsScreen.route,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: confetti,
              builder: (_, _) => CustomPaint(
                painter: _ConfettiPainter(
                  confetti.value,
                  theme.accent,
                  theme.primary,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareDialog(BuildContext context, CompletionResult result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Share result'),
        content: _ShareCard(data: result.shareCard),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _victoryMessage(CompletionResult result) {
    if (result.noMistake && result.hintsUsed == 0) return 'Perfect Solve!';
    if (result.seconds <= 300) return 'You crushed it!';
    if (result.difficulty == Difficulty.extreme) return 'Mind Master!';
    final messages = ['Brilliant!', 'Genius Move!', 'Beautiful focus!'];
    return messages[result.seconds % messages.length];
  }

  CompletionResult _previewResult(AppController app) {
    final board =
        app.currentGame?.solution ??
        [
          [5, 3, 4, 6, 7, 8, 9, 1, 2],
          [6, 7, 2, 1, 9, 5, 3, 4, 8],
          [1, 9, 8, 3, 4, 2, 5, 6, 7],
          [8, 5, 9, 7, 6, 1, 4, 2, 3],
          [4, 2, 6, 8, 5, 3, 7, 9, 1],
          [7, 1, 3, 9, 2, 4, 8, 5, 6],
          [9, 6, 1, 5, 3, 7, 2, 8, 4],
          [2, 8, 7, 4, 1, 9, 6, 3, 5],
          [3, 4, 5, 2, 8, 6, 1, 7, 9],
        ];
    final difficulty = app.currentGame?.difficulty ?? Difficulty.easy;
    final seconds = app.currentGame?.seconds ?? 514;
    return CompletionResult(
      difficulty: difficulty,
      seconds: seconds,
      score: app.currentGame?.score ?? 5200,
      xp: 95,
      coins: 32,
      accuracy: 98,
      board: board,
      noMistake: true,
      hintsUsed: 0,
      dailyChallenge: false,
      levelTitle: RetentionEngine().levelTitleFor(app.stats.level),
      shareCard: RetentionEngine().shareCardFor(
        app.stats,
        difficulty,
        seconds,
        98,
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.data});
  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return Container(
      width: 280,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GridyMascot(size: 52),
          const SizedBox(height: 12),
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final line in data.lines)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                line,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            data.accent,
            style: TextStyle(color: theme.accent, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _PreviewBoard extends StatelessWidget {
  const _PreviewBoard({required this.board});
  final List<List<int>> board;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (_, i) => Center(
          child: Text(
            '${board[i ~/ 9][i % 9]}',
            style: TextStyle(
              color: theme.number,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return Column(
      children: [
        Icon(icon, color: theme.primary),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.a, this.b);
  final double t;
  final Color a;
  final Color b;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < 34; i++) {
      final x = (i * 47 % size.width).toDouble();
      final y = (t * size.height * .72 + i * 19) % size.height;
      paint.color = i.isEven ? a : b;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 8, 12),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}
