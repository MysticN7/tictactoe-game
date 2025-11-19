import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isConfettiEnabled = true;
  int _boardSize = 3;
  int _winCondition = 3;
  GameThemeMode _currentTheme = GameThemeMode.liquidGlow;
  List<PlayerConfig> _playerConfigs = [
    PlayerConfig(player: Player.x, name: 'Player X', icon: 'X'),
    PlayerConfig(player: Player.o, name: 'Player O', icon: 'O'),
    PlayerConfig(player: Player.triangle, name: 'Player △', icon: '△'),
  ];
  List<Player> _activePlayers = [Player.x, Player.o];
  GameMode _gameMode = GameMode.pvp;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;

  Future<void> loadPersistence() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundEnabled = prefs.getBool('isSoundEnabled') ?? _isSoundEnabled;
    _isVibrationEnabled = prefs.getBool('isVibrationEnabled') ?? _isVibrationEnabled;
    _isConfettiEnabled = prefs.getBool('isConfettiEnabled') ?? _isConfettiEnabled;
    for (final config in _playerConfigs) {
      final name = prefs.getString('player_${config.player.name}_name');
      final icon = prefs.getString('player_${config.player.name}_icon');
      if (name != null) config.name = name;
      if (icon != null) config.icon = icon;
      if (name != null) config.name = name;
      if (icon != null) config.icon = icon;
    }
    final modeIndex = prefs.getInt('gameMode');
    if (modeIndex != null) _gameMode = GameMode.values[modeIndex];
    final diffIndex = prefs.getInt('aiDifficulty');
    if (diffIndex != null) _aiDifficulty = AIDifficulty.values[diffIndex];
    notifyListeners();
  }

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;
  bool get isConfettiEnabled => _isConfettiEnabled;
  int get boardSize => _boardSize;
  int get winCondition => _winCondition;
  GameThemeMode get currentTheme => _currentTheme;
  List<PlayerConfig> get playerConfigs => _playerConfigs;
  List<Player> get activePlayers => _activePlayers;
  GameMode get gameMode => _gameMode;
  AIDifficulty get aiDifficulty => _aiDifficulty;

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    SharedPreferences.getInstance().then((p) => p.setBool('isSoundEnabled', _isSoundEnabled));
    notifyListeners();
  }

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    SharedPreferences.getInstance().then((p) => p.setBool('isVibrationEnabled', _isVibrationEnabled));
    notifyListeners();
  }

  void toggleConfetti() {
    _isConfettiEnabled = !_isConfettiEnabled;
    SharedPreferences.getInstance().then((p) => p.setBool('isConfettiEnabled', _isConfettiEnabled));
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
    final sanitized = _sanitizeName(name);
    final index = _playerConfigs.indexWhere((config) => config.player == player);
    if (index != -1) {
      _playerConfigs[index] = PlayerConfig(
        player: player,
        name: sanitized,
        icon: _playerConfigs[index].icon,
      );
      SharedPreferences.getInstance().then((p) => p.setString('player_${player.name}_name', sanitized));
      notifyListeners();
    }
  }

  void updatePlayerIcon(Player player, String icon) {
    final sanitized = _sanitizeIcon(icon);
    final index = _playerConfigs.indexWhere((config) => config.player == player);
    if (index != -1) {
      _playerConfigs[index] = PlayerConfig(
        player: player,
        name: _playerConfigs[index].name,
        icon: sanitized,
      );
      SharedPreferences.getInstance().then((p) => p.setString('player_${player.name}_icon', sanitized));
      notifyListeners();
    }
  }

  void setActivePlayers(List<Player> players) {
    if (players.length >= 2 && players.length <= 3) {
      _activePlayers = players;
      notifyListeners();
    }
  }

  void setGameMode(GameMode mode) {
    _gameMode = mode;
    SharedPreferences.getInstance().then((p) => p.setInt('gameMode', mode.index));
    notifyListeners();
  }

  void setAIDifficulty(AIDifficulty difficulty) {
    _aiDifficulty = difficulty;
    SharedPreferences.getInstance().then((p) => p.setInt('aiDifficulty', difficulty.index));
    notifyListeners();
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

  String _sanitizeName(String name) {
    final trimmed = name.trim();
    final restricted = trimmed.replaceAll(RegExp(r'[^A-Za-z0-9 _-]'), '');
    if (restricted.isEmpty) return 'Player';
    return restricted.length > 12 ? restricted.substring(0, 12) : restricted;
  }

  String _sanitizeIcon(String icon) {
    final trimmed = icon.trim();
    if (trimmed.isEmpty) return '?';
    final restricted = trimmed.replaceAll(RegExp(r'[^A-Za-z0-9△XO]'), '');
    return restricted.length > 2 ? restricted.substring(0, 2) : restricted;
  }
}

enum GameMode { pvp, pve, tournament }
enum AIDifficulty { easy, medium, hard, impossible }
