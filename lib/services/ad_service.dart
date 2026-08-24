import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  // Keep the AdMob integration in place, but disable all ad activity until the
  // production App ID and ad unit IDs are ready.
  static const bool adsEnabled = false;

  static const String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // Google test ID
      : 'ca-app-pub-XXXXX/YYYYY'; // Production ID

  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Google test ID
      : 'ca-app-pub-XXXXX/YYYYY'; // Production ID

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  int _interstitialCounter = 0;
  static const int _interstitialFrequency = 3;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!adsEnabled) return;
    if (_initialized) return;
    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      _loadRewardedAd();
      _loadInterstitialAd();
    } catch (e) {
      debugPrint('AdMob init failed: $e');
    }
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  bool get isRewardedAdReady => adsEnabled && _rewardedAd != null;

  Future<bool> showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    if (!adsEnabled) {
      onFailed();
      return false;
    }

    if (_rewardedAd == null) {
      onFailed();
      return false;
    }

    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        if (rewarded) onRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
        onFailed();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        rewarded = true;
      },
    );

    _rewardedAd = null;
    return rewarded;
  }

  bool get shouldShowInterstitial {
    if (!adsEnabled) return false;
    _interstitialCounter++;
    return _interstitialCounter % _interstitialFrequency == 0;
  }

  Future<void> showInterstitialAd() async {
    if (!adsEnabled) return;

    if (_interstitialAd == null) {
      _loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
