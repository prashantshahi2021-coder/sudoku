import 'dart:math';

import '../retention_engine.dart';

enum BotDifficulty { easy, medium, hard }

enum RaceWinner { player, bot }

class RaceState {
  const RaceState({
    required this.bot,
    required this.mode,
    required this.seed,
    required this.botTimerSeconds,
    required this.playerTimerSeconds,
    required this.botProgress,
    required this.playerProgress,
    required this.botMistakes,
    required this.finished,
    this.winner,
    this.message = 'Match found. Stay sharp.',
  });

  final BotDifficulty bot;
  final GameMode mode;
  final int seed;
  final int botTimerSeconds;
  final int playerTimerSeconds;
  final double botProgress;
  final double playerProgress;
  final int botMistakes;
  final bool finished;
  final RaceWinner? winner;
  final String message;

  RaceState copyWith({
    int? botTimerSeconds,
    int? playerTimerSeconds,
    double? botProgress,
    double? playerProgress,
    int? botMistakes,
    bool? finished,
    RaceWinner? winner,
    String? message,
  }) {
    return RaceState(
      bot: bot,
      mode: mode,
      seed: seed,
      botTimerSeconds: botTimerSeconds ?? this.botTimerSeconds,
      playerTimerSeconds: playerTimerSeconds ?? this.playerTimerSeconds,
      botProgress: botProgress ?? this.botProgress,
      playerProgress: playerProgress ?? this.playerProgress,
      botMistakes: botMistakes ?? this.botMistakes,
      finished: finished ?? this.finished,
      winner: winner ?? this.winner,
      message: message ?? this.message,
    );
  }
}

class RaceEngine {
  RaceState start({
    required BotDifficulty bot,
    required GameMode mode,
    int seed = 0,
  }) {
    return RaceState(
      bot: bot,
      mode: mode,
      seed: seed,
      botTimerSeconds: 0,
      playerTimerSeconds: 0,
      botProgress: 0,
      playerProgress: 0,
      botMistakes: 0,
      finished: false,
      message: '3... 2... 1... GO!',
    );
  }

  RaceState tick(
    RaceState state, {
    required int elapsedSeconds,
    required int playerFilledCells,
  }) {
    if (state.finished) return state;
    final botTargetSeconds = switch (state.bot) {
      BotDifficulty.easy => 620,
      BotDifficulty.medium => 470,
      BotDifficulty.hard => 330,
    };
    final jitter = (sin((elapsedSeconds + state.seed) / 19) * .035);
    final botProgress = (elapsedSeconds / botTargetSeconds + jitter).clamp(
      0.0,
      1.0,
    );
    final playerProgress = (playerFilledCells / 81).clamp(0.0, 1.0);
    final botMistakes = switch (state.bot) {
      BotDifficulty.easy => elapsedSeconds ~/ 210,
      BotDifficulty.medium => elapsedSeconds ~/ 360,
      BotDifficulty.hard => 0,
    };
    final finished = playerProgress >= 1 || botProgress >= 1;
    final winner = finished
        ? playerProgress >= 1 && playerProgress >= botProgress
              ? RaceWinner.player
              : RaceWinner.bot
        : null;
    return state.copyWith(
      botTimerSeconds: elapsedSeconds,
      playerTimerSeconds: elapsedSeconds,
      botProgress: botProgress,
      playerProgress: playerProgress,
      botMistakes: botMistakes,
      finished: finished,
      winner: winner,
      message: finished
          ? winner == RaceWinner.player
                ? 'You outraced the bot!'
                : 'The bot finished first. Rematch?'
          : playerProgress >= botProgress
          ? 'You are ahead. Keep the rhythm.'
          : 'Gridy says the bot is pulling ahead.',
    );
  }
}
