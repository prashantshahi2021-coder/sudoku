import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/models.dart';
import 'package:sudoku/engine/retention_engine.dart';

void main() {
  test('completion rewards include bonuses and unlock achievements', () {
    final engine = RetentionEngine();
    final result = engine.applyCompletion(
      stats: const PlayerStats(),
      difficulty: Difficulty.extreme,
      seconds: 280,
      mistakes: 0,
      hintsUsed: 0,
      dailyChallenge: true,
      completedAt: DateTime(2026, 5, 10),
    );

    expect(result.stats.gamesWon, 1);
    expect(result.stats.currentStreak, 1);
    expect(result.stats.coins, greaterThan(120));
    expect(result.stats.xp, greaterThan(200));
    expect(
      result.stats.achievementIds,
      containsAll([
        'first_win',
        'no_mistake_master',
        'hint_free_hero',
        'extreme_winner',
        'speed_solver',
      ]),
    );
    expect(result.levelTitle, 'Beginner');
    expect(result.newAchievements.length, greaterThanOrEqualTo(4));
  });

  test('streak freeze preserves a streak after one missed day', () {
    final engine = RetentionEngine();
    final stats = const PlayerStats(
      gamesWon: 4,
      currentStreak: 4,
      longestStreak: 4,
      streakFreezes: 1,
      lastPlayedDay: '2026-05-08',
    );

    final result = engine.applyCompletion(
      stats: stats,
      difficulty: Difficulty.easy,
      seconds: 700,
      mistakes: 1,
      hintsUsed: 1,
      dailyChallenge: false,
      completedAt: DateTime(2026, 5, 10),
    );

    expect(result.stats.currentStreak, 5);
    expect(result.stats.streakFreezes, 0);
    expect(result.usedFreeze, isTrue);
  });

  test('daily reward is claimable once per local day', () {
    final engine = RetentionEngine();
    const stats = PlayerStats(lastDailyRewardDay: '2026-05-09');

    final reward = engine.claimDailyReward(stats, DateTime(2026, 5, 10));
    final duplicate = engine.claimDailyReward(
      reward.stats,
      DateTime(2026, 5, 10),
    );

    expect(reward.claimed, isTrue);
    expect(reward.stats.coins, stats.coins + 12);
    expect(duplicate.claimed, isFalse);
  });

  test('share card and notification prep use local data only', () {
    final engine = RetentionEngine();
    const stats = PlayerStats(
      gamesWon: 12,
      currentStreak: 7,
      xp: 920,
      level: 4,
    );

    final share = engine.shareCardFor(stats, Difficulty.hard, 420, 96);
    final notification = engine.notificationPrepFor(stats);

    expect(share.title, 'Sudoku Hard solved');
    expect(share.lines.join(' '), contains('7 day streak'));
    expect(notification.dailyChallengeMessage, contains('brain workout'));
    expect(notification.streakReminderMessage, contains('7 day streak'));
  });
}
