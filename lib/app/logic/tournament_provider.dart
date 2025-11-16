import 'package:flutter/material.dart';
import 'tournament_logic.dart';

class TournamentProvider with ChangeNotifier {
  TournamentLogic? _tournament;

  TournamentLogic? get tournament => _tournament;

  void startTournament(List<String> players) {
    _tournament = TournamentLogic(players);
    notifyListeners();
  }

  void recordWin(String winner) {
    _tournament?.recordGameWinner(winner);
    notifyListeners();
  }

  void endTournament() {
    _tournament = null;
    notifyListeners();
  }
}