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
       // If we just switched to tournament, start it
       if (tournament.currentRound == 1 && tournament.activePlayers.length == 3) {
          // Already setup or just started?
          // Let's force start if we are not in a valid tournament state
       }
       // For simplicity, whenever we switch to Tournament, let's reset/start it
       startTournament();
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
    final currentPlayerBeforeMove = _gameLogic.currentPlayer;
    if (_gameLogic.makeMove(row, col)) {
      _playFeedback();

      // Check if the move resulted in a win (even if game is not over)
      // In GameLogic, winner is set to the player who just won.
      // If winner matches the player who just moved, it's a win.
      // Note: GameLogic might have switched currentPlayer already if game continues.
      
      if (_gameLogic.winner == currentPlayerBeforeMove) {
         // It's a win!
         _scoresProvider?.increment(_gameLogic.winner!);
         _playWinFeedback();
         
         if (_settingsProvider?.gameMode == GameMode.tournament) {
            _handleTournamentWin(_gameLogic.winner!);
         } else {
            // In non-tournament (PvP/PvE), we usually stop at first win unless we want survival there too?
            // The user request specifically mentioned "Tournament" for this 3-player survival.
            // But if we are in 3-player PvP, maybe we should also do survival?
            // "where people can play with 3 players and compete with each other... 3 players will start playing..."
            // It sounds like this IS the 3-player mode.
            // So if activePlayers > 2, we continue.
            
            if (_gameLogic.isGameOver) {
               _saveMatch();
               AdMobService.showInterstitialAd();
            } else {
               // Game continues, show a toast or something?
               // For now, just let it continue.
            }
         }
      } else if (_gameLogic.isGameOver && _gameLogic.winner == null) {
         // Draw (Board full and no winner, or all eliminated?)
         _playDrawFeedback();
         if (_settingsProvider?.gameMode != GameMode.tournament) {
            _saveMatch();
            AdMobService.showInterstitialAd();
         }
      } else {
        // Normal move, no win yet
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
    // In the new survival logic, GameLogic handles the "activePlayers" removal.
    // We just need to track the tournament state (Round 1 winner, Round 2 winner).
    
    if (tournament.currentRound == 1) {
      tournament.round1Winner = winner;
      // Game continues for 2nd place
      tournament.currentRound = 2;
    } else if (tournament.currentRound == 2) {
      tournament.round2Winner = winner;
      // Now game is over (2 winners found).
      // The 3rd player is the loser.
      final loser = tournament.activePlayers.firstWhere((p) => p != winner && p != tournament.round1Winner, orElse: () => Player.triangle); // Fallback
      tournament.eliminatedPlayers.add(loser);
      
      // Setup Final Match
      tournament.currentRound = 3;
      tournament.activePlayers = [tournament.round1Winner!, tournament.round2Winner!];
      
      // We need to reset the board for the final match
      // But we should probably wait for user to click "Next Match" or similar?
      // For now, let's just update state. The UI should show "Round 2 Over, Start Final".
    } else if (tournament.currentRound == 3) {
      tournament.champion = winner;
      final loser = tournament.activePlayers.firstWhere((p) => p != winner);
      tournament.eliminatedPlayers.add(loser);
    }
    notifyListeners();
  }

  void startNextRound() {
    if (tournament.currentRound == 3) {
      // Starting Final Match
      _gameLogic.updatePlayers(tournament.activePlayers);
      resetGame();
    }
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
