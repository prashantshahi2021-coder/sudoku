import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../../data/models.dart';

enum AppSound { tap, mistake, win, countdown }

class AppFeedback {
  AppFeedback._();

  static final AudioPlayer _effectPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  static final AudioPlayer _ambientPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.loop);

  static SettingsState _settings = const SettingsState();
  static bool _ambientActive = false;

  static Future<void> configure(SettingsState settings) async {
    _settings = settings;
    if (!settings.sound || !settings.ambientSounds) {
      await stopAmbient();
      return;
    }
    await startAmbient();
  }

  static Future<void> tap() async {
    await haptic(HapticKind.selection);
    await sound(AppSound.tap);
  }

  static Future<void> haptic(HapticKind kind) async {
    if (!_settings.haptics) return;
    switch (kind) {
      case HapticKind.selection:
        await HapticFeedback.selectionClick();
      case HapticKind.light:
        await HapticFeedback.lightImpact();
      case HapticKind.warning:
        await HapticFeedback.mediumImpact();
      case HapticKind.success:
        await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> sound(AppSound sound) async {
    if (!_settings.sound) return;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setVolume(switch (sound) {
        AppSound.tap => .18,
        AppSound.mistake => .28,
        AppSound.win => .36,
        AppSound.countdown => .2,
      });
      await _effectPlayer.play(AssetSource(_assetFor(sound)));
    } catch (_) {
      // Audio should never interrupt gameplay.
    }
  }

  static Future<void> startAmbient() async {
    if (_ambientActive || !_settings.sound || !_settings.ambientSounds) return;
    try {
      await _ambientPlayer.setVolume(.08);
      await _ambientPlayer.play(AssetSource('audio/ambient.wav'));
      _ambientActive = true;
    } catch (_) {
      _ambientActive = false;
    }
  }

  static Future<void> pauseAmbient() async {
    if (!_ambientActive) return;
    await _ambientPlayer.pause();
  }

  static Future<void> resumeAmbient() async {
    if (!_settings.sound || !_settings.ambientSounds) return;
    if (_ambientActive) {
      await _ambientPlayer.resume();
    } else {
      await startAmbient();
    }
  }

  static Future<void> stopAmbient() async {
    _ambientActive = false;
    await _ambientPlayer.stop();
  }

  static Future<void> dispose() async {
    await _effectPlayer.dispose();
    await _ambientPlayer.dispose();
  }

  static String _assetFor(AppSound sound) => switch (sound) {
    AppSound.tap => 'audio/tap.wav',
    AppSound.mistake => 'audio/mistake.wav',
    AppSound.win => 'audio/win.wav',
    AppSound.countdown => 'audio/countdown.wav',
  };
}

enum HapticKind { selection, light, warning, success }
