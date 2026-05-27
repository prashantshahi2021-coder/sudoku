import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/app_controller.dart';
import '../../engine/retention_engine.dart';
import '../../engine/sudoku_types.dart';
import '../../shared/services/app_feedback.dart';
import '../../shared/widgets/premium_widgets.dart';
import '../complete/level_complete_screen.dart';
import '../home/home_screen.dart';
import 'game_state.dart';
import 'sudoku_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});
  static const route = '/game';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final game = app.currentGame;
    if (game == null) {
      return PremiumScaffold(
        child: Center(
          child: PillButton(
            label: 'Back home',
            icon: Icons.home_rounded,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, HomeScreen.route),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: game,
      builder: (context, _) {
        if (game.complete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushReplacementNamed(
                context,
                LevelCompleteScreen.route,
              );
            }
          });
        }
        return PremiumScaffold(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          game.mode == GameMode.classic
                              ? game.difficulty.label
                              : '${game.difficulty.label} • ${_modeLabel(game.mode)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: game.togglePause,
                        icon: Icon(
                          game.paused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Complete preview',
                        onPressed: () => Navigator.pushNamed(
                          context,
                          LevelCompleteScreen.route,
                        ),
                        icon: const Icon(Icons.emoji_events_rounded),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (game.mode == GameMode.relax)
                        const _StatusChip(
                          icon: Icons.spa_rounded,
                          label: 'Relax',
                        )
                      else
                        ValueListenableBuilder<int>(
                          valueListenable: game.secondsListenable,
                          builder: (_, seconds, _) => _StatusChip(
                            icon: Icons.timer_rounded,
                            label: formatTime(seconds),
                          ),
                        ),
                      _StatusChip(
                        icon: Icons.close_rounded,
                        label: 'Mistakes ${game.mistakes}/3',
                      ),
                      _StatusChip(
                        icon: Icons.stars_rounded,
                        label: '${game.score}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PremiumCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const GridyMascot(size: 34),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            game.coachMessage,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SudokuBoard(game: game),
                  const SizedBox(height: 16),
                  _ToolRow(game: game),
                  const SizedBox(height: 12),
                  _NumberPad(game: game),
                ],
              ),
              Positioned(
                left: app.settings.leftHandedMode ? 4 : null,
                right: app.settings.leftHandedMode ? null : 4,
                bottom: 94,
                child: FloatingActionButton(
                  heroTag: 'gridy',
                  onPressed: () => _openGridy(context, game),
                  child: const GridyMascot(mood: 'hint', size: 40),
                ),
              ),
              if (game.paused)
                Positioned.fill(
                  child: Container(
                    color: app.activeTheme.background.withValues(alpha: .78),
                    child: Center(
                      child: PremiumCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const GridyMascot(mood: 'thinking', size: 78),
                            const SizedBox(height: 12),
                            Text(
                              'Paused',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 10),
                            PillButton(
                              label: 'Resume',
                              icon: Icons.play_arrow_rounded,
                              onPressed: game.togglePause,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static void _openGridy(BuildContext context, GameState game) {
    final theme = AppScope.of(context).activeTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: theme.shadow,
              blurRadius: 28,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const GridyMascot(mood: 'hint', size: 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gridy',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Smart hint, not a spoiler',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.highlightCell,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                game.smartHint(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: 'Smart hint',
                    icon: Icons.lightbulb_rounded,
                    onPressed: () async {
                      if (_hintsLimited(game)) return;
                      final app = AppScope.of(context);
                      final allowed = await app.consumeHintCreditIfNeeded(
                        game.hintsUsed,
                      );
                      if (!allowed && context.mounted) {
                        _showRewardedHintPrompt(context);
                        return;
                      }
                      game.requestHint(HintRequest.smart);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PillButton(
                    label: 'Reveal Cell',
                    icon: Icons.visibility_rounded,
                    onPressed: () async {
                      if (_hintsLimited(game)) return;
                      final app = AppScope.of(context);
                      final allowed = await app.consumeHintCreditIfNeeded(
                        game.hintsUsed,
                      );
                      if (!allowed && context.mounted) {
                        _showRewardedHintPrompt(context);
                        return;
                      }
                      game.requestHint(HintRequest.reveal);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static bool _hintsLimited(GameState game) =>
      (game.mode == GameMode.speedChallenge ||
          game.mode == GameMode.scoreAttack) &&
      game.hintsUsed >= 3;

  static void _showRewardedHintPrompt(BuildContext context) {
    final app = AppScope.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('No hints left'),
        content: Text(
          app.adService.rewardedHintPrompt(
            hintsUsed: app.currentGame?.hintsUsed ?? 0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () async {
              await app.grantRewardedHintCredit();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Watch'),
          ),
        ],
      ),
    );
  }

  static String _modeLabel(GameMode mode) => switch (mode) {
    GameMode.relax => 'Relax',
    GameMode.speedChallenge => 'Speed',
    GameMode.scoreAttack => 'Score',
    GameMode.classic => 'Classic',
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.primary),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.undo_rounded, 'Undo', game.undo, false),
      (Icons.backspace_rounded, 'Erase', game.erase, false),
      (Icons.edit_note_rounded, 'Notes', game.toggleNotes, game.notesMode),
      (
        Icons.lightbulb_rounded,
        'Hint',
        () => GameScreen._openGridy(context, game),
        false,
      ),
    ];
    final ordered = AppScope.of(context).settings.leftHandedMode
        ? actions.reversed.toList()
        : actions;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ordered
          .map(
            (a) =>
                _ToolButton(icon: a.$1, label: a.$2, onTap: a.$3, active: a.$4),
          )
          .toList(),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SudokuIconTile(
      icon: icon,
      label: label,
      onTap: onTap,
      active: active,
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.activeTheme;
    final numbers = app.settings.leftHandedMode
        ? List.generate(9, (i) => 9 - i)
        : List.generate(9, (i) => i + 1);
    return Row(
      children: List.generate(9, (i) {
        final n = numbers[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 8 ? 0 : 6),
            child: AspectRatio(
              aspectRatio: .72,
              child: FilledButton(
                onPressed: () async {
                  await AppFeedback.tap();
                  if (app.settings.mistakeLimit && game.mistakes >= 3) {
                    return;
                  }
                  final beforeComplete = game.complete;
                  final beforeMistakes = game.mistakes;
                  final correct = game.input(
                    n,
                    autoCleanup: app.settings.autoNotesCleanup,
                  );
                  if (correct) {
                    await AppFeedback.haptic(
                      game.complete && !beforeComplete
                          ? HapticKind.success
                          : HapticKind.light,
                    );
                    if (game.complete && !beforeComplete) {
                      await AppFeedback.sound(AppSound.win);
                    }
                  } else if (game.mistakes > beforeMistakes) {
                    await AppFeedback.haptic(HapticKind.warning);
                    await AppFeedback.sound(AppSound.mistake);
                  } else {
                    await AppFeedback.haptic(HapticKind.selection);
                  }
                },
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: theme.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontSize: app.settings.largeNumbers ? 26 : 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
