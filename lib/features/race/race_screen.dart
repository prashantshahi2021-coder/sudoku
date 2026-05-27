import 'dart:async';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/app_controller.dart';
import '../../data/models.dart';
import '../../engine/race/race_engine.dart';
import '../../engine/retention_engine.dart';
import '../../shared/services/app_feedback.dart';
import '../../shared/widgets/premium_widgets.dart';
import '../game/game_state.dart';
import '../game/sudoku_board.dart';

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});
  static const route = '/race';

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  BotDifficulty bot = BotDifficulty.medium;
  Difficulty difficulty = Difficulty.medium;
  RaceState? race;
  Timer? timer;
  int seconds = 0;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = AppScope.of(context).currentGame;
    return PremiumScaffold(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: race == null || game == null
          ? _setup(context)
          : _liveRace(context, game, race!),
    );
  }

  Widget _setup(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Text('Race Mode', style: Theme.of(context).textTheme.headlineLarge),
        Text(
          'Local bot race today. Online matchmaking is prepared for later.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your rival',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final option in BotDifficulty.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    bot == option
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: AppScope.of(context).activeTheme.primary,
                  ),
                  onTap: () => setState(() => bot = option),
                  title: Text(
                    '${option.name[0].toUpperCase()}${option.name.substring(1)} Bot',
                  ),
                  subtitle: Text(_botDescription(option)),
                ),
            ],
          ),
        ),
        const Spacer(),
        PillButton(
          label: 'Start Race',
          icon: Icons.bolt_rounded,
          onPressed: _startRace,
        ),
      ],
    );
  }

  Widget _liveRace(BuildContext context, GameState game, RaceState race) {
    final app = AppScope.of(context);
    return AnimatedBuilder(
      animation: game,
      builder: (context, _) {
        final playerCells = game.board
            .expand((row) => row)
            .where((value) => value != 0)
            .length;
        final live = RaceEngine().tick(
          race,
          elapsedSeconds: seconds,
          playerFilledCells: playerCells,
        );
        return Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    '3... 2... 1... GO!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const GridyMascot(size: 42),
              ],
            ),
            PremiumCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _Progress(
                    label: 'You',
                    value: live.playerProgress,
                    timer: formatTime(live.playerTimerSeconds),
                  ),
                  const SizedBox(height: 10),
                  _Progress(
                    label: '${bot.name} bot',
                    value: live.botProgress,
                    timer: formatTime(live.botTimerSeconds),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    live.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SudokuBoard(game: game),
            const SizedBox(height: 12),
            _RacePad(game: game),
            if (live.finished)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: PremiumCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: app.activeTheme.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          live.message,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _startRace() async {
    await AppScope.of(
      context,
    ).startGame(difficulty, mode: GameMode.speedChallenge);
    seconds = 0;
    race = RaceEngine().start(
      bot: bot,
      mode: GameMode.speedChallenge,
      seed: DateTime.now().millisecondsSinceEpoch,
    );
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        if (seconds < 3) AppFeedback.sound(AppSound.countdown);
        setState(() => seconds++);
      }
    });
    await AppFeedback.sound(AppSound.countdown);
    setState(() {});
  }

  String _botDescription(BotDifficulty bot) => switch (bot) {
    BotDifficulty.easy => 'Slow, gentle, occasional mistakes',
    BotDifficulty.medium => 'Balanced pace and pressure',
    BotDifficulty.hard => 'Fast and accurate',
  };
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.label,
    required this.value,
    required this.timer,
  });
  final String label;
  final double value;
  final String timer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: LinearProgressIndicator(value: value)),
        const SizedBox(width: 10),
        Text(timer, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _RacePad extends StatelessWidget {
  const _RacePad({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Row(
      children: List.generate(9, (i) {
        final n = i + 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 8 ? 0 : 5),
            child: FilledButton(
              onPressed: () async {
                await AppFeedback.tap();
                final beforeMistakes = game.mistakes;
                final correct = game.input(
                  n,
                  autoCleanup: app.settings.autoNotesCleanup,
                );
                if (correct) {
                  await AppFeedback.haptic(HapticKind.light);
                } else if (game.mistakes > beforeMistakes) {
                  await AppFeedback.haptic(HapticKind.warning);
                  await AppFeedback.sound(AppSound.mistake);
                } else {
                  await AppFeedback.haptic(HapticKind.selection);
                }
              },
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(34, 48),
              ),
              child: Text(
                '$n',
                style: TextStyle(
                  fontSize: app.settings.largeNumbers ? 18 : null,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
