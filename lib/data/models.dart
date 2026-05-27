enum Difficulty {
  easy('Easy', 38, 1.0, 1),
  medium('Medium', 44, 1.25, 2),
  hard('Hard', 50, 1.55, 3),
  expert('Expert', 54, 1.85, 4),
  master('Master', 56, 2.2, 5),
  extreme('Extreme', 58, 2.6, 6);

  const Difficulty(
    this.label,
    this.emptyCells,
    this.multiplier,
    this.minimumLogicalScore,
  );
  final String label;
  final int emptyCells;
  final double multiplier;
  final int minimumLogicalScore;
}

class PlayerStats {
  const PlayerStats({
    this.gamesWon = 0,
    this.bestScore = 0,
    this.bestTime = 0,
    this.totalTime = 0,
    this.noMistakeWins = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.xp = 0,
    this.coins = 120,
    this.level = 1,
    this.streakFreezes = 0,
    this.lastPlayedDay,
    this.lastDailyRewardDay,
    this.achievementIds = const [],
    this.puzzleHistory = const [],
    this.favoriteDifficulty = 'Easy',
  });

  final int gamesWon;
  final int bestScore;
  final int bestTime;
  final int totalTime;
  final int noMistakeWins;
  final int currentStreak;
  final int longestStreak;
  final int xp;
  final int coins;
  final int level;
  final int streakFreezes;
  final String? lastPlayedDay;
  final String? lastDailyRewardDay;
  final List<String> achievementIds;
  final List<String> puzzleHistory;
  final String favoriteDifficulty;

  int get averageTime => gamesWon == 0 ? 0 : totalTime ~/ gamesWon;

  PlayerStats copyWith({
    int? gamesWon,
    int? bestScore,
    int? bestTime,
    int? totalTime,
    int? noMistakeWins,
    int? currentStreak,
    int? longestStreak,
    int? xp,
    int? coins,
    int? level,
    int? streakFreezes,
    String? lastPlayedDay,
    String? lastDailyRewardDay,
    List<String>? achievementIds,
    List<String>? puzzleHistory,
    String? favoriteDifficulty,
  }) {
    return PlayerStats(
      gamesWon: gamesWon ?? this.gamesWon,
      bestScore: bestScore ?? this.bestScore,
      bestTime: bestTime ?? this.bestTime,
      totalTime: totalTime ?? this.totalTime,
      noMistakeWins: noMistakeWins ?? this.noMistakeWins,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastPlayedDay: lastPlayedDay ?? this.lastPlayedDay,
      lastDailyRewardDay: lastDailyRewardDay ?? this.lastDailyRewardDay,
      achievementIds: achievementIds ?? this.achievementIds,
      puzzleHistory: puzzleHistory ?? this.puzzleHistory,
      favoriteDifficulty: favoriteDifficulty ?? this.favoriteDifficulty,
    );
  }

  Map<String, Object> toJson() => {
    'gamesWon': gamesWon,
    'bestScore': bestScore,
    'bestTime': bestTime,
    'totalTime': totalTime,
    'noMistakeWins': noMistakeWins,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'xp': xp,
    'coins': coins,
    'level': level,
    'streakFreezes': streakFreezes,
    'lastPlayedDay': lastPlayedDay ?? '',
    'lastDailyRewardDay': lastDailyRewardDay ?? '',
    'achievementIds': achievementIds,
    'puzzleHistory': puzzleHistory,
    'favoriteDifficulty': favoriteDifficulty,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    gamesWon: json['gamesWon'] as int? ?? 0,
    bestScore: json['bestScore'] as int? ?? 0,
    bestTime: json['bestTime'] as int? ?? 0,
    totalTime: json['totalTime'] as int? ?? 0,
    noMistakeWins: json['noMistakeWins'] as int? ?? 0,
    currentStreak: json['currentStreak'] as int? ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    xp: json['xp'] as int? ?? 0,
    coins: json['coins'] as int? ?? 120,
    level: json['level'] as int? ?? 1,
    streakFreezes: json['streakFreezes'] as int? ?? 0,
    lastPlayedDay: (json['lastPlayedDay'] as String?)?.isEmpty == true
        ? null
        : json['lastPlayedDay'] as String?,
    lastDailyRewardDay: (json['lastDailyRewardDay'] as String?)?.isEmpty == true
        ? null
        : json['lastDailyRewardDay'] as String?,
    achievementIds:
        (json['achievementIds'] as List<dynamic>?)?.cast<String>() ?? const [],
    puzzleHistory:
        (json['puzzleHistory'] as List<dynamic>?)?.cast<String>() ?? const [],
    favoriteDifficulty: json['favoriteDifficulty'] as String? ?? 'Easy',
  );
}

class SettingsState {
  const SettingsState({
    this.sound = true,
    this.haptics = true,
    this.mistakeLimit = true,
    this.autoNotesCleanup = true,
    this.largeNumbers = false,
    this.colorblindSafe = false,
    this.leftHandedMode = false,
    this.ambientSounds = false,
    this.premium = false,
    this.extraHintCredits = 0,
    this.completedGamesSinceAd = 0,
  });

  final bool sound;
  final bool haptics;
  final bool mistakeLimit;
  final bool autoNotesCleanup;
  final bool largeNumbers;
  final bool colorblindSafe;
  final bool leftHandedMode;
  final bool ambientSounds;
  final bool premium;
  final int extraHintCredits;
  final int completedGamesSinceAd;

  SettingsState copyWith({
    bool? sound,
    bool? haptics,
    bool? mistakeLimit,
    bool? autoNotesCleanup,
    bool? largeNumbers,
    bool? colorblindSafe,
    bool? leftHandedMode,
    bool? ambientSounds,
    bool? premium,
    int? extraHintCredits,
    int? completedGamesSinceAd,
  }) {
    return SettingsState(
      sound: sound ?? this.sound,
      haptics: haptics ?? this.haptics,
      mistakeLimit: mistakeLimit ?? this.mistakeLimit,
      autoNotesCleanup: autoNotesCleanup ?? this.autoNotesCleanup,
      largeNumbers: largeNumbers ?? this.largeNumbers,
      colorblindSafe: colorblindSafe ?? this.colorblindSafe,
      leftHandedMode: leftHandedMode ?? this.leftHandedMode,
      ambientSounds: ambientSounds ?? this.ambientSounds,
      premium: premium ?? this.premium,
      extraHintCredits: extraHintCredits ?? this.extraHintCredits,
      completedGamesSinceAd:
          completedGamesSinceAd ?? this.completedGamesSinceAd,
    );
  }

  Map<String, Object> toJson() => {
    'sound': sound,
    'haptics': haptics,
    'mistakeLimit': mistakeLimit,
    'autoNotesCleanup': autoNotesCleanup,
    'largeNumbers': largeNumbers,
    'colorblindSafe': colorblindSafe,
    'leftHandedMode': leftHandedMode,
    'ambientSounds': ambientSounds,
    'premium': premium,
    'extraHintCredits': extraHintCredits,
    'completedGamesSinceAd': completedGamesSinceAd,
  };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
    sound: json['sound'] as bool? ?? true,
    haptics: json['haptics'] as bool? ?? true,
    mistakeLimit: json['mistakeLimit'] as bool? ?? true,
    autoNotesCleanup: json['autoNotesCleanup'] as bool? ?? true,
    largeNumbers: json['largeNumbers'] as bool? ?? false,
    colorblindSafe: json['colorblindSafe'] as bool? ?? false,
    leftHandedMode: json['leftHandedMode'] as bool? ?? false,
    ambientSounds: json['ambientSounds'] as bool? ?? false,
    premium: json['premium'] as bool? ?? false,
    extraHintCredits: json['extraHintCredits'] as int? ?? 0,
    completedGamesSinceAd: json['completedGamesSinceAd'] as int? ?? 0,
  );
}
