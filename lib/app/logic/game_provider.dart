import 'package:flutter/material.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_logic.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/utils/admob_service.dart';
import 'package:tic_tac_toe_3_player/app/utils/sound_service.dart';

class GameProvider extends ChangeNotifier {
  GameLogic _gameLogic;
  SettingsProvider? _settingsProvider;

  GameProvider() : _gameLogic = GameLogic() {
    AdMobService.createInterstitialAd();
  }

  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
  }

  GameLogic get gameLogic => _gameLogic;

  void makeMove(int row, int col) {
    if (_gameLogic.makeMove(row, col)) {
      if (_settingsProvider?.isSoundEnabled ?? false) {
        SoundService.playTapSound();
      }
      if (_gameLogic.checkForWin(row, col)) {
        if (_settingsProvider?.isSoundEnabled ?? false) {
          SoundService.playWinSound();
        }
        AdMobService.showInterstitialAd();
      } else if (_gameLogic.isBoardFull()) {
        if (_settingsProvider?.isSoundEnabled ?? false) {
          SoundService.playDrawSound();
        }
        AdMobService.showInterstitialAd();
      }
      notifyListeners();
    } else {
      if (_settingsProvider?.isSoundEnabled ?? false) {
        SoundService.playErrorSound();
      }
    }
  }

  void resetGame() {
    _gameLogic = GameLogic();
    AdMobService.createInterstitialAd();
    notifyListeners();
  }
}
