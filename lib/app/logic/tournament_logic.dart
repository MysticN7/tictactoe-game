class TournamentLogic {
  final List<String> initialPlayers;
  int currentRound = 1; // 1: 3-player, 2: remaining 2, 3: final

  String? round1Winner;
  String? round2Winner;
  String? tournamentWinner;

  TournamentLogic(this.initialPlayers);

  List<String> get playersForCurrentGame {
    if (currentRound == 1) return initialPlayers;
    if (currentRound == 2) {
      if (round1Winner == null) return [];
      return initialPlayers.where((p) => p != round1Winner).toList();
    }
    if (currentRound == 3) {
      if (round1Winner == null || round2Winner == null) return [];
      return [round1Winner!, round2Winner!];
    }
    return [];
  }

  void recordGameWinner(String winner) {
    if (currentRound == 1) {
      round1Winner = winner;
      currentRound = 2;
    } else if (currentRound == 2) {
      round2Winner = winner;
      currentRound = 3;
    } else if (currentRound == 3) {
      tournamentWinner = winner;
      currentRound = 4; // done
    }
  }

  bool get isOver => tournamentWinner != null;
}