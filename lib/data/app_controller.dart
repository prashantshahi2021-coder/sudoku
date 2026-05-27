import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/storage/local_store.dart';
import '../core/theme/app_theme.dart';
import '../core/auth/app_user.dart';
import '../core/auth/auth_repository.dart';
import '../engine/ads/ad_service.dart';
import '../engine/daily_challenge.dart';
import '../engine/retention_engine.dart';
import '../features/game/game_state.dart';
import '../shared/services/app_feedback.dart';
import '../storage/game_save_store.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  final LocalStore _store = LocalStore();
  final GameSaveStore _gameStore = GameSaveStore();
  final AuthRepository _auth = LocalFirebaseReadyAuthRepository();
  Timer? _timer;

  bool onboarded = false;
  String themeId = 'sky';
  Set<String> unlockedThemes = {'sky'};
  PlayerStats stats = const PlayerStats();
  SettingsState settings = const SettingsState();
  AppUser? user;
  GameState? currentGame;
  CompletionResult? lastResult;
  List<Achievement> latestAchievements = const [];
  DailyRewardResult? latestDailyReward;

  SudokuTheme get activeTheme => SudokuTheme.catalog[themeId]!;
  PremiumEntitlement get entitlement =>
      PremiumEntitlement(isPremium: settings.premium);
  AdService get adService => AdService(entitlement: entitlement);

  Future<void> load() async {
    onboarded = await _store.readBool('onboarded');
    themeId = await _store.readString('theme') ?? 'sky';
    final unlocked = await _store.readString('unlockedThemes');
    if (unlocked != null) {
      unlockedThemes = unlocked.split(',').where((e) => e.isNotEmpty).toSet();
    }
    final statsJson = await _store.readJson('stats');
    if (statsJson != null) {
      stats = PlayerStats.fromJson(statsJson);
    }
    final settingsJson = await _store.readJson('settings');
    if (settingsJson != null) {
      settings = SettingsState.fromJson(settingsJson);
    }
    await AppFeedback.configure(settings);
    final userJson = await _store.readJson('user');
    if (userJson != null) {
      user = AppUser.fromJson(userJson);
    }
    final gameJson = await _gameStore.readCurrentGame();
    if (gameJson != null) {
      _attachGame(GameState.fromJson(gameJson));
    }
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    onboarded = true;
    await _store.writeBool('onboarded', true);
    notifyListeners();
  }

  Future<void> signInWithGoogle({
    required String displayName,
    required String username,
  }) async {
    user = await _auth.signInWithGoogle(
      displayName: displayName,
      username: username,
    );
    onboarded = true;
    await _store.writeJson('user', user!.toJson());
    await _store.writeBool('onboarded', true);
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? username,
    String? photoUrl,
  }) async {
    final current = user;
    if (current == null) return;
    user = await _auth.updateProfile(
      current.copyWith(
        displayName: displayName,
        username: username,
        photoUrl: photoUrl,
        level: stats.level,
        xp: stats.xp,
        coins: stats.coins,
        premiumStatus: settings.premium,
      ),
    );
    await _store.writeJson('user', user!.toJson());
    notifyListeners();
  }

  Future<void> startGame(
    Difficulty difficulty, {
    GameMode mode = GameMode.classic,
  }) async {
    lastResult = null;
    latestAchievements = const [];
    _attachGame(GameState.newGame(difficulty, mode: mode));
    await saveGame();
    notifyListeners();
  }

  Future<void> startDailyChallenge({
    Difficulty difficulty = Difficulty.medium,
  }) async {
    lastResult = null;
    latestAchievements = const [];
    final puzzle = DailyChallengeService().generateFor(
      DateTime.now(),
      difficulty,
    );
    _attachGame(GameState.fromPuzzle(puzzle, mode: GameMode.classic));
    await saveGame();
    notifyListeners();
  }

  void _attachGame(GameState game) {
    _timer?.cancel();
    currentGame?.removeListener(_onGameChanged);
    currentGame = game..addListener(_onGameChanged);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      currentGame?.tick();
      unawaited(saveGame());
    });
  }

  void _onGameChanged() {
    unawaited(saveGame());
    if (currentGame?.complete == true && lastResult == null) {
      unawaited(completeGame());
    }
    notifyListeners();
  }

  Future<void> saveGame() async {
    final game = currentGame;
    if (game != null) await _gameStore.writeCurrentGame(game.toJson());
  }

  Future<void> completeGame() async {
    final game = currentGame;
    if (game == null) return;
    final accuracy = ((81 - game.mistakes).clamp(0, 81) / 81 * 100).round();
    final retention = RetentionEngine().applyCompletion(
      stats: stats,
      difficulty: game.difficulty,
      seconds: game.seconds,
      mistakes: game.mistakes,
      hintsUsed: game.hintsUsed,
      dailyChallenge: game.dailyId != null,
      completedAt: DateTime.now(),
    );
    latestAchievements = retention.newAchievements;
    lastResult = CompletionResult(
      difficulty: game.difficulty,
      seconds: game.seconds,
      score: game.score + retention.xpEarned,
      xp: retention.xpEarned,
      coins: retention.coinsEarned,
      accuracy: accuracy,
      board: game.solution,
      noMistake: game.mistakes == 0,
      hintsUsed: game.hintsUsed,
      dailyChallenge: game.dailyId != null,
      levelTitle: retention.levelTitle,
      shareCard: RetentionEngine().shareCardFor(
        retention.stats,
        game.difficulty,
        game.seconds,
        accuracy,
      ),
    );
    stats = retention.stats.copyWith(
      bestScore:
          retention.stats.bestScore == 0 ||
              game.score + retention.xpEarned > retention.stats.bestScore
          ? game.score + retention.xpEarned
          : retention.stats.bestScore,
    );
    settings = settings.copyWith(
      completedGamesSinceAd:
          adService.shouldShowInterstitial(
            completedGamesSinceAd: settings.completedGamesSinceAd + 1,
          )
          ? 0
          : settings.completedGamesSinceAd + 1,
    );
    if (user != null) {
      user = user!.copyWith(
        level: stats.level,
        xp: stats.xp,
        coins: stats.coins,
        premiumStatus: settings.premium,
      );
      await _store.writeJson('user', user!.toJson());
    }
    currentGame = null;
    await _gameStore.clearCurrentGame();
    await _store.writeJson('stats', stats.toJson());
    await _store.writeJson('settings', settings.toJson());
    notifyListeners();
  }

  Future<void> updateTheme(String id) async {
    final theme = SudokuTheme.catalog[id]!;
    if (!unlockedThemes.contains(id)) {
      if (stats.coins < theme.price) return;
      stats = stats.copyWith(coins: stats.coins - theme.price);
      unlockedThemes.add(id);
      await _store.writeString('unlockedThemes', unlockedThemes.join(','));
      await _store.writeJson('stats', stats.toJson());
    }
    themeId = id;
    await _store.writeString('theme', id);
    notifyListeners();
  }

  Future<void> updateSettings(SettingsState value) async {
    settings = value;
    await AppFeedback.configure(settings);
    if (user != null) {
      user = user!.copyWith(premiumStatus: settings.premium);
      await _store.writeJson('user', user!.toJson());
    }
    await _store.writeJson('settings', settings.toJson());
    notifyListeners();
  }

  Future<bool> consumeHintCreditIfNeeded(int hintsUsed) async {
    if (adService.canUseHint(
      hintsUsed: hintsUsed,
      extraHints: settings.extraHintCredits,
    )) {
      if (!entitlement.hasUnlimitedHints &&
          hintsUsed >= adService.freeHintLimit) {
        settings = settings.copyWith(
          extraHintCredits: settings.extraHintCredits - 1,
        );
        await _store.writeJson('settings', settings.toJson());
      }
      return true;
    }
    return false;
  }

  Future<void> grantRewardedHintCredit() async {
    final grant = adService.grantRewardedHint(
      currentExtraHints: settings.extraHintCredits,
    );
    settings = settings.copyWith(extraHintCredits: grant.extraHints);
    await _store.writeJson('settings', settings.toJson());
    notifyListeners();
  }

  Future<DailyRewardResult> claimDailyReward() async {
    final reward = RetentionEngine().claimDailyReward(stats, DateTime.now());
    latestDailyReward = reward;
    if (reward.claimed) {
      stats = reward.stats;
      await _store.writeJson('stats', stats.toJson());
      notifyListeners();
    }
    return reward;
  }

  NotificationPrep get notificationPrep =>
      RetentionEngine().notificationPrepFor(stats);

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(AppFeedback.dispose());
    super.dispose();
  }
}

class CompletionResult {
  const CompletionResult({
    required this.difficulty,
    required this.seconds,
    required this.score,
    required this.xp,
    required this.coins,
    required this.accuracy,
    required this.board,
    required this.noMistake,
    required this.hintsUsed,
    required this.dailyChallenge,
    required this.levelTitle,
    required this.shareCard,
  });

  final Difficulty difficulty;
  final int seconds;
  final int score;
  final int xp;
  final int coins;
  final int accuracy;
  final List<List<int>> board;
  final bool noMistake;
  final int hintsUsed;
  final bool dailyChallenge;
  final String levelTitle;
  final ShareCardData shareCard;
}

String formatTime(int seconds) {
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final secs = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}
