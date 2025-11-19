import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io'; // Added for Platform.isAndroid/isIOS

class AdMobService {
  // NOTE: Using Google test ad units for development to verify integration
  // Banner (test): ca-app-pub-3940256099942544/6300978111
  // Interstitial (test): ca-app-pub-3940256099942544/1033173712
  //
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    throw UnsupportedError("Unsupported platform");
  }

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
