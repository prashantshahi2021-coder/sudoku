import '../data/models.dart';

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.coinReward = 8,
    this.xpReward = 20,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final int coinReward;
  final int xpReward;
}

class RetentionResult {
  const RetentionResult({
    required this.stats,
    required this.xpEarned,
    required this.coinsEarned,
    required this.newAchievements,
    required this.levelTitle,
    required this.usedFreeze,
  });

  final PlayerStats stats;
  final int xpEarned;
  final int coinsEarned;
  final List<Achievement> newAchievements;
  final String levelTitle;
  final bool usedFreeze;
}

class DailyRewardResult {
  const DailyRewardResult({
    required this.stats,
    required this.claimed,
    required this.xp,
    required this.coins,
    required this.message,
  });

  final PlayerStats stats;
  final bool claimed;
  final int xp;
  final int coins;
  final String message;
}

class ShareCardData {
  const ShareCardData({
    required this.title,
    required this.lines,
    required this.accent,
  });

  final String title;
  final List<String> lines;
  final String accent;
}

class NotificationPrep {
  const NotificationPrep({
    required this.dailyChallengeMessage,
    required this.streakReminderMessage,
  });

  final String dailyChallengeMessage;
  final String streakReminderMessage;
}

enum GameMode { classic, relax, speedChallenge, scoreAttack }

class RetentionEngine {
  static const achievements = [
    Achievement(
      id: 'first_win',
      title: 'First Win',
      description: 'Complete your first puzzle.',
      icon: 'trophy',
    ),
    Achievement(
      id: 'ten_wins',
      title: '10 Puzzles Solved',
      description: 'Finish 10 Sudoku puzzles.',
      icon: 'grid',
    ),
    Achievement(
      id: 'no_mistake_master',
      title: 'No Mistake Master',
      description: 'Win with zero mistakes.',
      icon: 'check',
    ),
    Achievement(
      id: 'seven_day_streak',
      title: '7 Day Streak',
      description: 'Train your brain for 7 days.',
      icon: 'flame',
    ),
    Achievement(
      id: 'hint_free_hero',
      title: 'Hint-Free Hero',
      description: 'Win without using hints.',
      icon: 'spark',
    ),
    Achievement(
      id: 'extreme_winner',
      title: 'Extreme Winner',
      description: 'Conquer an Extreme puzzle.',
      icon: 'mountain',
    ),
    Achievement(
      id: 'speed_solver',
      title: 'Speed Solver',
      description: 'Solve a puzzle in under 5 minutes.',
      icon: 'bolt',
    ),
  ];

  RetentionResult applyCompletion({
    required PlayerStats stats,
    required Difficulty difficulty,
    required int seconds,
    required int mistakes,
    required int hintsUsed,
    required bool dailyChallenge,
    required DateTime completedAt,
  }) {
    final day = _dayKey(completedAt);
    final streakInfo = _nextStreak(stats, day);
    final fastBonus = seconds <= 420 ? 30 : 0;
    final noMistakeBonus = mistakes == 0 ? 35 : 0;
    final hintFreeBonus = hintsUsed == 0 ? 25 : 0;
    final dailyBonus = dailyChallenge ? 35 : 0;
    final streakBonus = streakInfo.streak >= 2
        ? 10 + streakInfo.streak.clamp(0, 10)
        : 0;
    final xp =
        (70 * difficulty.multiplier).round() +
        fastBonus +
        noMistakeBonus +
        hintFreeBonus +
        dailyBonus +
        streakBonus;
    final coins =
        (18 * difficulty.multiplier).round() +
        (mistakes == 0 ? 12 : 0) +
        (dailyChallenge ? 12 : 0) +
        (streakInfo.streak >= 7 ? 15 : 0);
    final gamesWon = stats.gamesWon + 1;
    final newXp = stats.xp + xp;
    final unlocked = _unlockedAchievements(
      stats,
      gamesWon,
      streakInfo.streak,
      difficulty,
      seconds,
      mistakes,
      hintsUsed,
    );
    final achievementXp = unlocked.fold<int>(
      0,
      (sum, item) => sum + item.xpReward,
    );
    final achievementCoins = unlocked.fold<int>(
      0,
      (sum, item) => sum + item.coinReward,
    );
    final history = [
      '$day|${difficulty.label}|$seconds|$mistakes|$hintsUsed',
      ...stats.puzzleHistory,
    ].take(20).toList();

    final updated = stats.copyWith(
      gamesWon: gamesWon,
      currentStreak: streakInfo.streak,
      longestStreak: streakInfo.streak > stats.longestStreak
          ? streakInfo.streak
          : stats.longestStreak,
      streakFreezes: streakInfo.freezes,
      lastPlayedDay: day,
      xp: newXp + achievementXp,
      coins: stats.coins + coins + achievementCoins,
      level: (newXp + achievementXp) ~/ 300 + 1,
      noMistakeWins: stats.noMistakeWins + (mistakes == 0 ? 1 : 0),
      totalTime: stats.totalTime + seconds,
      bestTime: stats.bestTime == 0 || seconds < stats.bestTime
          ? seconds
          : stats.bestTime,
      bestScore: stats.bestScore,
      achievementIds: {
        ...stats.achievementIds,
        ...unlocked.map((a) => a.id),
      }.toList(),
      puzzleHistory: history,
      favoriteDifficulty: difficulty.label,
    );

    return RetentionResult(
      stats: updated,
      xpEarned: xp + achievementXp,
      coinsEarned: coins + achievementCoins,
      newAchievements: unlocked,
      levelTitle: levelTitleFor(updated.level),
      usedFreeze: streakInfo.usedFreeze,
    );
  }

  DailyRewardResult claimDailyReward(PlayerStats stats, DateTime now) {
    final day = _dayKey(now);
    if (stats.lastDailyRewardDay == day) {
      return DailyRewardResult(
        stats: stats,
        claimed: false,
        xp: 0,
        coins: 0,
        message: 'Daily reward already claimed.',
      );
    }
    final streakBoost = stats.currentStreak >= 7 ? 8 : 0;
    final coins = 12 + streakBoost;
    const xp = 25;
    return DailyRewardResult(
      stats: stats.copyWith(
        coins: stats.coins + coins,
        xp: stats.xp + xp,
        level: (stats.xp + xp) ~/ 300 + 1,
        lastDailyRewardDay: day,
      ),
      claimed: true,
      xp: xp,
      coins: coins,
      message: stats.currentStreak >= 7
          ? 'Mind on fire! Daily bonus boosted.'
          : 'Daily brain boost claimed.',
    );
  }

  ShareCardData shareCardFor(
    PlayerStats stats,
    Difficulty difficulty,
    int seconds,
    int accuracy,
  ) {
    return ShareCardData(
      title: 'Sudoku ${difficulty.label} solved',
      accent: levelTitleFor(stats.level),
      lines: [
        'Time ${_formatTime(seconds)}',
        'Accuracy $accuracy%',
        '${stats.currentStreak} day streak',
        '${stats.gamesWon} puzzles solved',
      ],
    );
  }

  NotificationPrep notificationPrepFor(PlayerStats stats) {
    return NotificationPrep(
      dailyChallengeMessage:
          'Your brain workout is waiting. Today\'s Sudoku challenge is ready.',
      streakReminderMessage: stats.currentStreak > 0
          ? 'Keep your ${stats.currentStreak} day streak alive with a calm puzzle.'
          : 'Start a fresh Sudoku streak today.',
    );
  }

  String levelTitleFor(int level) {
    if (level >= 30) return 'Legend';
    if (level >= 20) return 'Mastermind';
    if (level >= 14) return 'Genius';
    if (level >= 8) return 'Strategist';
    if (level >= 3) return 'Thinker';
    return 'Beginner';
  }

  Duration dailyCountdown(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1).difference(now);

  List<Achievement> _unlockedAchievements(
    PlayerStats stats,
    int gamesWon,
    int streak,
    Difficulty difficulty,
    int seconds,
    int mistakes,
    int hintsUsed,
  ) {
    bool locked(String id) => !stats.achievementIds.contains(id);
    return [
      if (gamesWon >= 1 && locked('first_win'))
        achievements.firstWhere((a) => a.id == 'first_win'),
      if (gamesWon >= 10 && locked('ten_wins'))
        achievements.firstWhere((a) => a.id == 'ten_wins'),
      if (mistakes == 0 && locked('no_mistake_master'))
        achievements.firstWhere((a) => a.id == 'no_mistake_master'),
      if (streak >= 7 && locked('seven_day_streak'))
        achievements.firstWhere((a) => a.id == 'seven_day_streak'),
      if (hintsUsed == 0 && locked('hint_free_hero'))
        achievements.firstWhere((a) => a.id == 'hint_free_hero'),
      if (difficulty == Difficulty.extreme && locked('extreme_winner'))
        achievements.firstWhere((a) => a.id == 'extreme_winner'),
      if (seconds <= 300 && locked('speed_solver'))
        achievements.firstWhere((a) => a.id == 'speed_solver'),
    ];
  }

  _StreakInfo _nextStreak(PlayerStats stats, String day) {
    final last = stats.lastPlayedDay;
    if (last == day) {
      return _StreakInfo(stats.currentStreak, stats.streakFreezes, false);
    }
    if (last == null) {
      return const _StreakInfo(1, 0, false);
    }
    final gap = DateTime.parse(day).difference(DateTime.parse(last)).inDays;
    if (gap == 1) {
      return _StreakInfo(stats.currentStreak + 1, stats.streakFreezes, false);
    }
    if (gap == 2 && stats.streakFreezes > 0) {
      return _StreakInfo(
        stats.currentStreak + 1,
        stats.streakFreezes - 1,
        true,
      );
    }
    return _StreakInfo(1, stats.streakFreezes, false);
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class _StreakInfo {
  const _StreakInfo(this.streak, this.freezes, this.usedFreeze);
  final int streak;
  final int freezes;
  final bool usedFreeze;
}
