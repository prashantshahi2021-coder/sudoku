import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../app.dart';
import '../../engine/ads/ad_service.dart';
import '../../engine/ads/mobile_ads_adapter.dart';

class PremiumBannerAdSlot extends StatefulWidget {
  const PremiumBannerAdSlot({super.key});

  @override
  State<PremiumBannerAdSlot> createState() => _PremiumBannerAdSlotState();
}

class _PremiumBannerAdSlotState extends State<PremiumBannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppScope.of(context);
    if (!AdService(entitlement: app.entitlement).shouldShowBanner ||
        kIsWeb ||
        !MobileAdsAdapter.hasBannerUnit ||
        _ad != null) {
      return;
    }
    try {
      _ad = BannerAd(
        adUnitId: MobileAdsAdapter.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) => mounted ? setState(() => _loaded = true) : null,
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
            if (mounted) setState(() => _loaded = false);
          },
        ),
      )..load();
    } catch (_) {
      _ad = null;
      _loaded = false;
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = app.activeTheme;
    if (!AdService(entitlement: app.entitlement).shouldShowBanner) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 58,
      margin: const EdgeInsets.only(top: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.card.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.boardLine),
      ),
      child: _loaded && _ad != null
          ? SizedBox(
              width: _ad!.size.width.toDouble(),
              height: _ad!.size.height.toDouble(),
              child: AdWidget(ad: _ad!),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sponsor message loading',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
    );
  }
}
