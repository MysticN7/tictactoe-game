import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String get bannerAdUnitId => 'ca-app-pub-4384120827738431/2390002413';
  static String get interstitialAdUnitId => 'ca-app-pub-4384120827738431/4237560263';

  static InterstitialAd? _interstitialAd;
  static bool _isLoadingInterstitial = false;
  static int _gamesSinceLastAd = 0;
  static int _gamesUntilNextAd = 0;
  static bool _shouldShowWhenReady = false;
  static final Random _random = Random();

  static void _scheduleNextInterstitial() {
    _gamesSinceLastAd = 0;
    // Alternate between showing after 1 or 2 games so it never feels too aggressive
    _gamesUntilNextAd = _random.nextBool() ? 1 : 2;
    if (kDebugMode) {
      print('AdMob: Next interstitial scheduled after $_gamesUntilNextAd game(s)');
    }
  }

  static void createInterstitialAd() {
    if (_isLoadingInterstitial) return; // Prevent multiple simultaneous loads
    
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
          if (_gamesUntilNextAd == 0) {
            _scheduleNextInterstitial();
          }
          if (_shouldShowWhenReady && _gamesSinceLastAd >= _gamesUntilNextAd) {
            _showInterstitialAdInternal();
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
            if (_interstitialAd == null) {
              createInterstitialAd();
            }
          });
        },
      ),
    );
    if (_gamesUntilNextAd == 0) {
      _scheduleNextInterstitial();
    }
  }

  static void showInterstitialAd() {
    _gamesSinceLastAd++;
    if (kDebugMode) {
      print('AdMob: Games since last interstitial: $_gamesSinceLastAd / $_gamesUntilNextAd');
    }

    if (_gamesSinceLastAd >= _gamesUntilNextAd) {
      if (_interstitialAd != null) {
        _showInterstitialAdInternal();
      } else {
        _shouldShowWhenReady = true;
        if (!_isLoadingInterstitial) {
          createInterstitialAd();
        }
      }
    } else if (_interstitialAd == null && !_isLoadingInterstitial) {
      // Warm up the next ad in the background even if we haven't reached the threshold yet.
      createInterstitialAd();
    }
  }

  static void _showInterstitialAdInternal() {
    if (_interstitialAd == null) return;

    _shouldShowWhenReady = false;

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
        _scheduleNextInterstitial();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('AdMob: Interstitial ad failed to show: ${error.code} - ${error.message}');
        }
        ad.dispose();
        _interstitialAd = null;
        _scheduleNextInterstitial();
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
