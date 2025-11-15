import 'package:flutter/material.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_logic.dart';

enum GameThemeMode { light, dark, liquidGlow }

class PlayerConfig {
  final Player player;
  String name;
  String icon;

  PlayerConfig({
    required this.player,
    required this.name,
    required this.icon,
  });
}

class SettingsProvider extends ChangeNotifier {
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  int _boardSize = 3;
  int _winCondition = 3;
  GameThemeMode _currentTheme = GameThemeMode.liquidGlow;
  List<PlayerConfig> _playerConfigs = [
    PlayerConfig(player: Player.x, name: 'Player X', icon: 'X'),
    PlayerConfig(player: Player.o, name: 'Player O', icon: 'O'),
    PlayerConfig(player: Player.triangle, name: 'Player △', icon: '△'),
  ];
  List<Player> _activePlayers = [Player.x, Player.o];

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;
  int get boardSize => _boardSize;
  int get winCondition => _winCondition;
  GameThemeMode get currentTheme => _currentTheme;
  List<PlayerConfig> get playerConfigs => _playerConfigs;
  List<Player> get activePlayers => _activePlayers;

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    notifyListeners();
  }

  void setBoardSize(int size) {
    if (size >= 3 && size <= 5) {
      _boardSize = size;
      notifyListeners();
    }
  }

  void setWinCondition(int condition) {
    if (condition >= 3 && condition <= 5) {
      _winCondition = condition;
      notifyListeners();
    }
  }

  void setTheme(GameThemeMode theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  void updatePlayerName(Player player, String name) {
    final index = _playerConfigs.indexWhere((config) => config.player == player);
    if (index != -1) {
      _playerConfigs[index] = PlayerConfig(
        player: player,
        name: name,
        icon: _playerConfigs[index].icon,
      );
      notifyListeners();
    }
  }

  void updatePlayerIcon(Player player, String icon) {
    final index = _playerConfigs.indexWhere((config) => config.player == player);
    if (index != -1) {
      _playerConfigs[index] = PlayerConfig(
        player: player,
        name: _playerConfigs[index].name,
        icon: icon,
      );
      notifyListeners();
    }
  }

  void setActivePlayers(List<Player> players) {
    if (players.length >= 2 && players.length <= 3) {
      _activePlayers = players;
      notifyListeners();
    }
  }

  String getPlayerName(Player player) {
    final config = _playerConfigs.firstWhere(
      (config) => config.player == player,
      orElse: () => PlayerConfig(player: player, name: player.toString().split('.').last, icon: '?'),
    );
    return config.name;
  }

  String getPlayerIcon(Player player) {
    final config = _playerConfigs.firstWhere(
      (config) => config.player == player,
      orElse: () => PlayerConfig(player: player, name: 'Player', icon: '?'),
    );
    return config.icon;
  }

  Color getPlayerColor(Player player) {
    switch (player) {
      case Player.x:
        return const Color(0xFFFF1744); // Red
      case Player.o:
        return const Color(0xFF2196F3); // Blue
      case Player.triangle:
        return const Color(0xFFFFEB3B); // Yellow
    }
  }
}
