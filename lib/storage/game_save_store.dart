import 'package:hive_flutter/hive_flutter.dart';

class GameSaveStore {
  static const _boxName = 'sudoku_game_saves';
  static const _currentGameKey = 'current_game';
  static const _dailyStreakKey = 'daily_streak';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_boxName);
    _initialized = true;
  }

  Future<Box<dynamic>> get _box async {
    await init();
    return Hive.isBoxOpen(_boxName)
        ? Hive.box<dynamic>(_boxName)
        : Hive.openBox<dynamic>(_boxName);
  }

  Future<Map<String, dynamic>?> readCurrentGame() async {
    final raw = (await _box).get(_currentGameKey);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> writeCurrentGame(Map<String, Object?> game) async {
    await (await _box).put(_currentGameKey, game);
  }

  Future<void> clearCurrentGame() async {
    await (await _box).delete(_currentGameKey);
  }

  Future<Map<String, dynamic>?> readDailyStreak() async {
    final raw = (await _box).get(_dailyStreakKey);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> writeDailyStreak(Map<String, Object?> value) async {
    await (await _box).put(_dailyStreakKey, value);
  }
}
