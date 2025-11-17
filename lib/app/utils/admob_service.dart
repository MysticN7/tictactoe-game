import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String get bannerAdUnitId => 'ca-app-pub-4384120827738431/2390002413';
  static String get interstitialAdUnitId => 'ca-app-pub-4384120827738431/4237560263';

  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;

  static void createInterstitialAd() {
    // Clean implementation based on Google Mobile Ads interstitial guide.
    if (_isLoadingInterstitial || _interstitialAd != null) return;
    
    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
          if (kDebugMode) {
            print('AdMob: Interstitial ad loaded successfully');
          }
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
          if (kDebugMode) {
            print('AdMob: Interstitial ad failed to load: ${error.code} - ${error.message}');
            print('AdMob: Domain: ${error.domain}, ResponseInfo: ${error.responseInfo}');
          }
          // Retry after a delay (exponential backoff)
          Future.delayed(const Duration(seconds: 30), () {
            if (_interstitialAd == null && !_isLoadingInterstitial) {
              createInterstitialAd();
            }
          });
        },
      ),
    );
  }

  /// Call this at the end of a match to show an interstitial if available.
  static void showInterstitialAd() {
    if (_interstitialAd == null) {
      // No ad ready; start loading so a future match can show it.
      if (!_isLoadingInterstitial) {
        createInterstitialAd();
      }
      if (kDebugMode) {
        print('AdMob: No interstitial ready at match end');
      }
      return;
    }

    if (kDebugMode) {
      print('AdMob: Showing interstitial ad');
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) {
          print('AdMob: Interstitial ad dismissed');
        }
        ad.dispose();
        _interstitialAd = null;
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('AdMob: Interstitial ad failed to show: ${error.code} - ${error.message}');
        }
        ad.dispose();
        _interstitialAd = null;
        createInterstitialAd();
      },
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) {
          print('AdMob: Interstitial ad showed');
        }
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
