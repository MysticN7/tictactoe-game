import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String get bannerAdUnitId => 'ca-app-pub-4384120827738431/2390002413';
  static String get interstitialAdUnitId => 'ca-app-pub-4384120827738431/4237560263';

  static InterstitialAd? _interstitialAd;
  static int _winsSinceLastAd = 0;
  static int _winsUntilNextAd = 0;
  static final Random _random = Random();

  static void _resetAdCounter() {
    // Randomly decide to show ad after 1, 2, or 3 wins
    _winsUntilNextAd = _random.nextInt(3) + 1; // 1, 2, or 3
    _winsSinceLastAd = 0;
  }

  static void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
    // Initialize ad counter on first load
    if (_winsUntilNextAd == 0) {
      _resetAdCounter();
    }
  }

  static void showInterstitialAd() {
    _winsSinceLastAd++;
    
    // Only show ad if we've reached the target number of wins
    if (_winsSinceLastAd >= _winsUntilNextAd && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _resetAdCounter(); // Reset counter after showing ad
          createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _resetAdCounter();
          createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else if (_interstitialAd == null) {
      // Preload next ad if we don't have one
      createInterstitialAd();
    }
  }
}
