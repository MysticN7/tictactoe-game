import 'package:flutter/material.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_logic.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/scores_provider.dart';
import 'package:tic_tac_toe_3_player/app/utils/admob_service.dart';
import 'package:tic_tac_toe_3_player/app/utils/sound_service.dart';
import 'package:tic_tac_toe_3_player/app/utils/vibration_service.dart';

class GameMatch {
  final DateTime timestamp;
  final Player? winner;
  final int boardSize;
  final int winCondition;
  final int moveCount;

  GameMatch({
    required this.timestamp,
    this.winner,
    required this.boardSize,
    required this.winCondition,
    required this.moveCount,
  });
}

class GameProvider extends ChangeNotifier {
  GameLogic _gameLogic;
  SettingsProvider? _settingsProvider;
  ScoresProvider? _scoresProvider;
  List<GameMatch> _matchHistory = [];

  GameProvider() : _gameLogic = GameLogic() {
    AdMobService.createInterstitialAd();
  }

  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
    _settingsProvider?.addListener(_onSettingsChanged);
    _updateGameFromSettings();
  }

  void setScoresProvider(ScoresProvider scoresProvider) {
    _scoresProvider = scoresProvider;
  }

  void _onSettingsChanged() {
    _updateGameFromSettings();
  }

  void _updateGameFromSettings() {
    if (_settingsProvider == null) return;

    final needsReset = _gameLogic.boardSize != _settingsProvider!.boardSize ||
        _gameLogic.winCondition != _settingsProvider!.winCondition ||
        _gameLogic.players.length != _settingsProvider!.activePlayers.length ||
        !_gameLogic.players.every((p) => _settingsProvider!.activePlayers.contains(p));

    if (needsReset) {
      _gameLogic.updateBoardSize(_settingsProvider!.boardSize);
      _gameLogic.updateWinCondition(_settingsProvider!.winCondition);
      _gameLogic.updatePlayers(_settingsProvider!.activePlayers);
      notifyListeners();
    }
  }

  GameLogic get gameLogic => _gameLogic;
  List<GameMatch> get matchHistory => _matchHistory;

  void makeMove(int row, int col) {
    if (_gameLogic.makeMove(row, col)) {
      if (_settingsProvider?.isSoundEnabled ?? false) {
        SoundService.playTapSound();
      }
      if (_settingsProvider?.isVibrationEnabled ?? false) {
        VibrationService.vibrate();
      }

      if (_gameLogic.isGameOver) {
        if (_gameLogic.winner != null) {
          _scoresProvider?.increment(_gameLogic.winner!);
          if (_settingsProvider?.isSoundEnabled ?? false) {
            SoundService.playWinSound();
          }
          if (_settingsProvider?.isVibrationEnabled ?? false) {
            VibrationService.vibratePattern();
          }
        } else {
          if (_settingsProvider?.isSoundEnabled ?? false) {
            SoundService.playDrawSound();
          }
        }

        // Save match to history
        _matchHistory.insert(0, GameMatch(
          timestamp: DateTime.now(),
          winner: _gameLogic.winner,
          boardSize: _gameLogic.boardSize,
          winCondition: _gameLogic.winCondition,
          moveCount: _gameLogic.moveHistory.length,
        ));

        AdMobService.showInterstitialAd();
      }
      notifyListeners();
    } else {
      if (_settingsProvider?.isSoundEnabled ?? false) {
        SoundService.playErrorSound();
      }
    }
  }

  bool undoLastMove() {
    if (_gameLogic.undoLastMove()) {
      if (_settingsProvider?.isSoundEnabled ?? false) {
        SoundService.playTapSound();
      }
      if (_settingsProvider?.isVibrationEnabled ?? false) {
        VibrationService.vibrate(duration: 30);
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void resetGame() {
    _gameLogic = GameLogic(
      boardSize: _settingsProvider?.boardSize ?? 3,
      winCondition: _settingsProvider?.winCondition ?? 3,
      players: _settingsProvider?.activePlayers ?? [Player.x, Player.o],
    );
    AdMobService.createInterstitialAd();
    notifyListeners();
  }

  void clearMatchHistory() {
    _matchHistory.clear();
    notifyListeners();
  }
}
