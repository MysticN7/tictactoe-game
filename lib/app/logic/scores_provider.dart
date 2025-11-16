import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_logic.dart';

class ScoresProvider with ChangeNotifier {
  final Map<Player, int> _wins = {Player.x: 0, Player.o: 0, Player.triangle: 0};
  bool _loaded = false;

  Map<Player, int> get wins => Map.unmodifiable(_wins);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    for (final p in Player.values) {
      _wins[p] = prefs.getInt('wins_${p.name}') ?? 0;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> increment(Player player) async {
    _wins[player] = (_wins[player] ?? 0) + 1;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wins_${player.name}', _wins[player]!);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    for (final p in Player.values) {
      _wins[p] = 0;
      await prefs.setInt('wins_${p.name}', 0);
    }
    notifyListeners();
  }
}