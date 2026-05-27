class PremiumEntitlement {
  const PremiumEntitlement({
    required this.isPremium,
    this.unlimitedRace = false,
    this.unlimitedHints = false,
  });

  final bool isPremium;
  final bool unlimitedRace;
  final bool unlimitedHints;

  bool get removesAds => isPremium;
  bool get hasUnlimitedHints => isPremium || unlimitedHints;
}

class RewardedHintGrant {
  const RewardedHintGrant({required this.extraHints});
  final int extraHints;
}

class AdService {
  const AdService({required this.entitlement, this.freeHintLimit = 3});

  final PremiumEntitlement entitlement;
  final int freeHintLimit;

  bool get shouldShowBanner => !entitlement.removesAds;

  bool canUseHint({required int hintsUsed, int extraHints = 0}) {
    if (entitlement.hasUnlimitedHints) return true;
    return hintsUsed < freeHintLimit + extraHints;
  }

  String rewardedHintPrompt({required int hintsUsed}) {
    if (canUseHint(hintsUsed: hintsUsed)) return 'Hint ready.';
    return 'No hints left. Watch a short video to unlock one extra hint.';
  }

  RewardedHintGrant grantRewardedHint({required int currentExtraHints}) {
    if (entitlement.hasUnlimitedHints) {
      return RewardedHintGrant(extraHints: currentExtraHints);
    }
    return RewardedHintGrant(extraHints: currentExtraHints + 1);
  }

  bool shouldShowInterstitial({required int completedGamesSinceAd}) {
    if (entitlement.removesAds) return false;
    return completedGamesSinceAd >= 2;
  }
}
