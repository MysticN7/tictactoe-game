import 'package:flutter/material.dart';
import 'game_logic.dart';

class ScoresProvider with ChangeNotifier {
  // Session-based win counts (reset on app restart, like match history)
  final Map<Player, int> _wins = {Player.x: 0, Player.o: 0, Player.triangle: 0};

  Map<Player, int> get wins => Map.unmodifiable(_wins);

  Future<void> load() async {
    // No longer loading from persistence - session-based only
    // This ensures win counts reset on app restart, just like match history
    notifyListeners();
  }

  Future<void> increment(Player player) async {
    _wins[player] = (_wins[player] ?? 0) + 1;
    notifyListeners();
    // No longer persisting to SharedPreferences - session-based only
  }

  Future<void> reset() async {
    for (final p in Player.values) {
      _wins[p] = 0;
    }
    notifyListeners();
  }
}