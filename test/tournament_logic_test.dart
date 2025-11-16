import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_3_player/app/logic/tournament_logic.dart';

void main() {
  test('Tournament progresses 3->2->final', () {
    final t = TournamentLogic(['A','B','C']);
    expect(t.currentRound, 1);
    expect(t.playersForCurrentGame.length, 3);

    t.recordGameWinner('A');
    expect(t.currentRound, 2);
    expect(t.playersForCurrentGame, ['B','C']);

    t.recordGameWinner('B');
    expect(t.currentRound, 3);
    expect(t.playersForCurrentGame, ['A','B']);

    t.recordGameWinner('A');
    expect(t.isOver, true);
    expect(t.tournamentWinner, 'A');
  });
}