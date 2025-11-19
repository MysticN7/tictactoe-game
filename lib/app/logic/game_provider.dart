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

class TournamentState {
  int currentRound = 1;
  Player? round1Winner;
  Player? round2Winner;
  Player? champion;
  List<Player> activePlayers = [Player.x, Player.o, Player.triangle];
  List<Player> eliminatedPlayers = [];
  List<Player> waitingPlayers = [];

  void reset() {
    currentRound = 1;
    round1Winner = null;
    round2Winner = null;
    champion = null;
    activePlayers = [Player.x, Player.o, Player.triangle];
    eliminatedPlayers = [];
    waitingPlayers = [];
  }
}

class GameProvider extends ChangeNotifier {
  GameLogic _gameLogic;
  SettingsProvider? _settingsProvider;
  ScoresProvider? _scoresProvider;
  List<GameMatch> _matchHistory = [];
  final TournamentState tournament = TournamentState();

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
    if (_settingsProvider?.gameMode == GameMode.tournament) {
       // If switching TO tournament mode, we might want to initialize it
       // But usually we start tournament explicitly.
       // For now, just update logic if NOT tournament
    } else {
      _updateGameFromSettings();
    }
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

  void startTournament() {
    tournament.reset();
    // Round 1: All 3 players
    _gameLogic.updatePlayers([Player.x, Player.o, Player.triangle]);
    resetGame();
  }

  void makeMove(int row, int col) {
    if (_gameLogic.makeMove(row, col)) {
      _playFeedback();

      if (_gameLogic.isGameOver) {
        if (_gameLogic.winner != null) {
          _scoresProvider?.increment(_gameLogic.winner!);
          _playWinFeedback();
          
          if (_settingsProvider?.gameMode == GameMode.tournament) {
            _handleTournamentWin(_gameLogic.winner!);
          } else {
            _saveMatch();
            AdMobService.showInterstitialAd();
          }
        } else {
          _playDrawFeedback();
          if (_settingsProvider?.gameMode != GameMode.tournament) {
             _saveMatch();
             AdMobService.showInterstitialAd();
          }
        }
      } else {
        _handleAiTurn();
      }
      notifyListeners();
    } else {
      if (_settingsProvider?.isSoundEnabled ?? false) {
        SoundService.playErrorSound();
      }
    }
  }

  void _handleTournamentWin(Player winner) {
    if (tournament.currentRound == 1) {
      tournament.round1Winner = winner;
      tournament.waitingPlayers.add(winner);
      tournament.activePlayers.remove(winner);
      tournament.currentRound = 2;
    } else if (tournament.currentRound == 2) {
      tournament.round2Winner = winner;
      final loser = tournament.activePlayers.firstWhere((p) => p != winner);
      tournament.eliminatedPlayers.add(loser);
      tournament.currentRound = 3;
      tournament.activePlayers = [tournament.round1Winner!, tournament.round2Winner!];
    } else if (tournament.currentRound == 3) {
      tournament.champion = winner;
      final loser = tournament.activePlayers.firstWhere((p) => p != winner);
      tournament.eliminatedPlayers.add(loser);
    }
    notifyListeners();
  }

  void startNextRound() {
    if (tournament.currentRound == 2) {
      _gameLogic.updatePlayers(tournament.activePlayers);
    } else if (tournament.currentRound == 3) {
      _gameLogic.updatePlayers(tournament.activePlayers);
    }
    resetGame();
  }

  void _handleAiTurn() {
    if (_settingsProvider?.gameMode == GameMode.pve && !_gameLogic.isGameOver) {
      // Simple AI logic: if current player is NOT the first player (Player X), assume it's AI
      // This allows Player X to be human, and others to be AI if we want
      // For now, let's stick to: Player X is Human, others are AI in PvE
      if (_gameLogic.currentPlayer != Player.x) {
         _makeAiMove();
      }
    }
  }

  Future<void> _makeAiMove() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_gameLogic.isGameOver) return;

    final difficulty = _settingsProvider?.aiDifficulty.index ?? 1;
    final move = _gameLogic.getBestMove(_gameLogic.currentPlayer!, difficulty);
    
    if (move != null) {
      makeMove(move.row, move.col);
    }
  }

  void _playFeedback() {
    if (_settingsProvider?.isSoundEnabled ?? false) SoundService.playTapSound();
    if (_settingsProvider?.isVibrationEnabled ?? false) VibrationService.vibrate();
  }

  void _playWinFeedback() {
    if (_settingsProvider?.isSoundEnabled ?? false) SoundService.playWinSound();
    if (_settingsProvider?.isVibrationEnabled ?? false) VibrationService.vibratePattern();
  }

  void _playDrawFeedback() {
    if (_settingsProvider?.isSoundEnabled ?? false) SoundService.playDrawSound();
  }

  void _saveMatch() {
    _matchHistory.insert(0, GameMatch(
      timestamp: DateTime.now(),
      winner: _gameLogic.winner,
      boardSize: _gameLogic.boardSize,
      winCondition: _gameLogic.winCondition,
      moveCount: _gameLogic.moveHistory.length,
    ));
    if (_matchHistory.length > 50) _matchHistory.removeLast();
  }

  bool undoLastMove() {
    if (_gameLogic.undoLastMove()) {
      if (_settingsProvider?.isSoundEnabled ?? false) SoundService.playTapSound();
      if (_settingsProvider?.isVibrationEnabled ?? false) VibrationService.vibrate(duration: 30);
      notifyListeners();
      return true;
    }
    return false;
  }

  void resetGame() {
    _gameLogic.reset();
    AdMobService.createInterstitialAd();
    notifyListeners();
  }

  void clearMatchHistory() {
    _matchHistory.clear();
    notifyListeners();
  }
}
