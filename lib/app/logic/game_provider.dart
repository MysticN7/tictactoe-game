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

enum TournamentRound {
  none,
  round1, // 3 players
  round2, // 2 losers from R1
  finalMatch, // Winner R1 vs Winner R2
  champion // Tournament Over
}

class GameProvider extends ChangeNotifier {
  GameLogic _gameLogic;
  SettingsProvider? _settingsProvider;
  ScoresProvider? _scoresProvider;
  List<GameMatch> _matchHistory = [];

  // Tournament State
  TournamentRound _tournamentRound = TournamentRound.none;
  Player? _round1Winner;
  Player? _round2Winner;
  Player? _tournamentChampion;
  List<Player> _round2Players = [];

  GameProvider() : _gameLogic = GameLogic() {
    AdMobService.createInterstitialAd();
  }

  TournamentRound get tournamentRound => _tournamentRound;
  Player? get round1Winner => _round1Winner;
  Player? get round2Winner => _round2Winner;
  Player? get tournamentChampion => _tournamentChampion;

  void setSettingsProvider(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
    _settingsProvider?.addListener(_onSettingsChanged);
    _updateGameFromSettings();
  }

  void setScoresProvider(ScoresProvider scoresProvider) {
    _scoresProvider = scoresProvider;
  }

  void _onSettingsChanged() {
    // If tournament is active, don't reset game on settings change unless critical
    if (_tournamentRound == TournamentRound.none) {
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
      
      // Reset scores if board size or win condition changed
      if (_gameLogic.boardSize != _settingsProvider!.boardSize || 
          _gameLogic.winCondition != _settingsProvider!.winCondition) {
        _scoresProvider?.reset();
      }
      notifyListeners();
    }
  }

  GameLogic get gameLogic => _gameLogic;
  List<GameMatch> get matchHistory => _matchHistory;

  void startTournament() {
    if (_settingsProvider == null) return;
    // Force 3 players for tournament if not already
    if (_settingsProvider!.activePlayers.length != 3) {
       _settingsProvider!.setActivePlayers([Player.x, Player.o, Player.triangle]);
    }
    
    _tournamentRound = TournamentRound.round1;
    _round1Winner = null;
    _round2Winner = null;
    _tournamentChampion = null;
    _round2Players = [];
    
    // Round 1: All 3 players
    _gameLogic = GameLogic(
      boardSize: _settingsProvider!.boardSize,
      winCondition: _settingsProvider!.winCondition,
      players: _settingsProvider!.activePlayers,
    );
    notifyListeners();
  }

  void stopTournament() {
    _tournamentRound = TournamentRound.none;
    resetGame();
  }

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
          _handleWin(_gameLogic.winner!);
        } else {
          _handleDraw();
        }

        // Save match to history
        _matchHistory.insert(0, GameMatch(
          timestamp: DateTime.now(),
          winner: _gameLogic.winner,
          boardSize: _gameLogic.boardSize,
          winCondition: _gameLogic.winCondition,
          moveCount: _gameLogic.moveHistory.length,
        ));

        // Smart Ads: 40% chance to show interstitial
        if (DateTime.now().millisecond % 10 < 4) {
           AdMobService.showInterstitialAd();
        }
      }
      notifyListeners();
    } else {
      if (_settingsProvider?.isSoundEnabled ?? false) {
        SoundService.playErrorSound();
      }
    }
  }

  void _handleWin(Player winner) {
    _scoresProvider?.increment(winner);
    if (_settingsProvider?.isSoundEnabled ?? false) {
      SoundService.playWinSound();
    }
    if (_settingsProvider?.isVibrationEnabled ?? false) {
      VibrationService.vibratePattern();
    }

    if (_tournamentRound != TournamentRound.none) {
      _advanceTournament(winner);
    }
  }

  void _handleDraw() {
    if (_settingsProvider?.isSoundEnabled ?? false) {
      SoundService.playDrawSound();
    }
    // In tournament, a draw might need a replay or handling. 
    // For now, let's just let them replay the round manually or auto-restart?
    // User didn't specify. Let's keep it as is, user can hit "Restart" to retry round.
  }

  void _advanceTournament(Player winner) {
    switch (_tournamentRound) {
      case TournamentRound.round1:
        _round1Winner = winner;
        // Identify losers
        final allPlayers = _settingsProvider!.activePlayers;
        _round2Players = allPlayers.where((p) => p != winner).toList();
        
        // Auto-start Round 2 after a delay or wait for user?
        // Let's wait for user to click "Next Match"
        break;
      case TournamentRound.round2:
        _round2Winner = winner;
        break;
      case TournamentRound.finalMatch:
        _tournamentChampion = winner;
        _tournamentRound = TournamentRound.champion;
        break;
      default:
        break;
    }
  }

  void nextTournamentMatch() {
    if (_tournamentRound == TournamentRound.round1 && _round1Winner != null) {
      // Start Round 2
      _tournamentRound = TournamentRound.round2;
      _gameLogic = GameLogic(
        boardSize: _settingsProvider!.boardSize,
        winCondition: _settingsProvider!.winCondition,
        players: _round2Players,
      );
    } else if (_tournamentRound == TournamentRound.round2 && _round2Winner != null) {
      // Start Final
      _tournamentRound = TournamentRound.finalMatch;
      _gameLogic = GameLogic(
        boardSize: _settingsProvider!.boardSize,
        winCondition: _settingsProvider!.winCondition,
        players: [_round1Winner!, _round2Winner!],
      );
    } else if (_tournamentRound == TournamentRound.champion) {
      // Restart Tournament
      startTournament();
    }
    notifyListeners();
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
    if (_tournamentRound != TournamentRound.none) {
      // In tournament, reset restarts the CURRENT match
      _gameLogic = GameLogic(
        boardSize: _settingsProvider?.boardSize ?? 3,
        winCondition: _settingsProvider?.winCondition ?? 3,
        players: _gameLogic.players, // Keep current round players
      );
    } else {
      _gameLogic = GameLogic(
        boardSize: _settingsProvider?.boardSize ?? 3,
        winCondition: _settingsProvider?.winCondition ?? 3,
        players: _settingsProvider?.activePlayers ?? [Player.x, Player.o],
      );
    }
    AdMobService.createInterstitialAd();
    notifyListeners();
  }

  void clearMatchHistory() {
    _matchHistory.clear();
    notifyListeners();
  }
}
