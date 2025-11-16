import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/app/logic/scores_provider.dart';
import 'package:tictactoe/app/logic/game_logic.dart';

void main() {
  test('Scores increment and reset work', () async {
    final s = ScoresProvider();
    await s.load();
    final before = s.wins[Player.x] ?? 0;
    await s.increment(Player.x);
    expect(s.wins[Player.x], before + 1);
    await s.reset();
    expect(s.wins[Player.x], 0);
  });
}