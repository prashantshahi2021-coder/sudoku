import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/engine/ads/ad_service.dart';
import 'package:sudoku/engine/race/race_engine.dart';
import 'package:sudoku/engine/retention_engine.dart';

void main() {
  test('free users get limited hints and rewarded ads grant one hint', () {
    final service = AdService(
      entitlement: const PremiumEntitlement(isPremium: false),
    );

    expect(service.canUseHint(hintsUsed: 0), isTrue);
    expect(service.canUseHint(hintsUsed: 3), isFalse);
    expect(service.rewardedHintPrompt(hintsUsed: 3), contains('Watch'));

    final grant = service.grantRewardedHint(currentExtraHints: 0);
    expect(grant.extraHints, 1);
    expect(
      service.canUseHint(hintsUsed: 3, extraHints: grant.extraHints),
      isTrue,
    );
  });

  test('premium users avoid ads and have unlimited hints', () {
    final service = AdService(
      entitlement: const PremiumEntitlement(isPremium: true),
    );

    expect(service.shouldShowBanner, isFalse);
    expect(service.canUseHint(hintsUsed: 99), isTrue);
    expect(service.shouldShowInterstitial(completedGamesSinceAd: 10), isFalse);
  });

  test('interstitials appear only after several completed games', () {
    final service = AdService(
      entitlement: const PremiumEntitlement(isPremium: false),
    );

    expect(service.shouldShowInterstitial(completedGamesSinceAd: 1), isFalse);
    expect(service.shouldShowInterstitial(completedGamesSinceAd: 2), isTrue);
  });

  test('race engine simulates bot progress and finish state', () {
    final race = RaceEngine().start(
      bot: BotDifficulty.medium,
      mode: GameMode.speedChallenge,
      seed: 7,
    );
    final updated = RaceEngine().tick(
      race,
      elapsedSeconds: 120,
      playerFilledCells: 42,
    );

    expect(updated.botProgress, greaterThan(0));
    expect(updated.playerProgress, closeTo(42 / 81, .001));
    expect(updated.botTimerSeconds, 120);

    final finished = RaceEngine().tick(
      updated,
      elapsedSeconds: 460,
      playerFilledCells: 81,
    );
    expect(finished.finished, isTrue);
    expect(finished.winner, isNotNull);
  });
}
