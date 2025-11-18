import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_logic.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/ui/theme.dart' as theme;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
    final themeType = settingsProvider.currentTheme.toAppThemeType();
    final gradientColors = theme.AppTheme.getGradientColors(themeType);

    return Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(color: Colors.black.withAlpha((0.2 * 255).round())),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      AppBar(
        title: const Text('Settings'),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            _buildSection(
                              context,
                              'Theme',
                              [
                                _buildThemeSelector(context, settingsProvider),
                              ],
                            ),
                            _buildSection(
                              context,
                              'Game Settings',
                              [
                                _buildBoardSizeSelector(context, settingsProvider),
                                const SizedBox(height: 16),
                                _buildWinConditionSelector(context, settingsProvider),
                                const SizedBox(height: 16),
                                _buildPlayerModeSelector(context, settingsProvider),
                              ],
                            ),
                            _buildSection(
                              context,
                              'Player Customization',
                              _buildPlayerCustomization(context, settingsProvider),
                            ),
                            _buildSection(
                              context,
                              'Audio & Haptics',
                              [
                                buildSwitchTile(
                                  context,
                                  'Sound',
                                  settingsProvider.isSoundEnabled,
                                  () => settingsProvider.toggleSound(),
                                  Icons.volume_up,
                                ),
                                buildSwitchTile(
                                  context,
                                  'Vibration',
                                  settingsProvider.isVibrationEnabled,
                                  () => settingsProvider.toggleVibration(),
                                  Icons.vibration,
                                ),
                                buildSwitchTile(
                                  context,
                                  'Confetti',
                                  settingsProvider.isConfettiEnabled,
                                  () => settingsProvider.toggleConfetti(),
                                  Icons.celebration,
                                ),
                              ],
                            ),
                            _buildSection(
                              context,
                              'About',
                              [
                                buildInfoTile(
                                  context,
                                  'App Version',
                                  _appVersion,
                                  Icons.info,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 24.0,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsProvider settingsProvider) {
    return _buildGlassCard(
      context,
      child: Column(
        children: [
                          _buildThemeOption(
            context,
            'Light',
            GameThemeMode.light,
            settingsProvider.currentTheme == GameThemeMode.light,
            () => settingsProvider.setTheme(GameThemeMode.light),
          ),
          const Divider(),
          _buildThemeOption(
            context,
            'Dark',
            GameThemeMode.dark,
            settingsProvider.currentTheme == GameThemeMode.dark,
            () => settingsProvider.setTheme(GameThemeMode.dark),
          ),
          const Divider(),
          _buildThemeOption(
            context,
            'Liquid Glow',
            GameThemeMode.liquidGlow,
            settingsProvider.currentTheme == GameThemeMode.liquidGlow,
            () => settingsProvider.setTheme(GameThemeMode.liquidGlow),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String name,
    GameThemeMode theme,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: onTap,
    );
  }

  Widget _buildBoardSizeSelector(BuildContext context, SettingsProvider settingsProvider) {
    return _buildGlassCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Board Size: ${settingsProvider.boardSize}x${settingsProvider.boardSize}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Slider(
            value: settingsProvider.boardSize.toDouble(),
            min: 3,
            max: 5,
            divisions: 2,
            label: '${settingsProvider.boardSize}x${settingsProvider.boardSize}',
            onChanged: (value) {
              settingsProvider.setBoardSize(value.toInt());
              Provider.of<GameProvider>(context, listen: false).resetGame();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWinConditionSelector(BuildContext context, SettingsProvider settingsProvider) {
    return _buildGlassCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Win Condition: ${settingsProvider.winCondition} in a row',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Row(
            children: [3, 4, 5].map((value) {
              return Expanded(
                child: RadioListTile<int>(
                  title: Text('$value'),
                  value: value,
                  groupValue: settingsProvider.winCondition,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      settingsProvider.setWinCondition(newValue);
                      Provider.of<GameProvider>(context, listen: false).resetGame();
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerModeSelector(BuildContext context, SettingsProvider settingsProvider) {
    final isTwoPlayer = settingsProvider.activePlayers.length == 2;
    final isThreePlayer = settingsProvider.activePlayers.length == 3;
    
    return _buildGlassCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Player Mode',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    context,
                    '2 Players',
                    'X  O',
                    isTwoPlayer,
                    () {
                      settingsProvider.setActivePlayers([Player.x, Player.o]);
                      Provider.of<GameProvider>(context, listen: false).resetGame();
                    },
                    settingsProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeButton(
                    context,
                    '3 Players',
                    'X  O  △',
                    isThreePlayer,
                    () {
                      settingsProvider.setActivePlayers([Player.x, Player.o, Player.triangle]);
                      Provider.of<GameProvider>(context, listen: false).resetGame();
                    },
                    settingsProvider,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String title,
    String icons,
    bool isSelected,
    VoidCallback onTap,
    SettingsProvider settingsProvider,
  ) {
    final themeType = settingsProvider.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: isSelected
              ? glassBorderColor.withAlpha((0.3 * 255).round())
              : glassColor,
          border: Border.all(
            color: isSelected
                ? glassBorderColor
                : glassBorderColor.withAlpha((0.5 * 255).round()),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              icons,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlayerCustomization(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return settingsProvider.playerConfigs.map((config) {
      final playerColor = settingsProvider.getPlayerColor(config.player);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildGlassCard(
          context,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: playerColor.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: playerColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      config.icon,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: playerColor,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  config.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${config.player.toString().split('.').last.toUpperCase()} Player'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _PlayerNameField(
                  initialValue: config.name,
                  label: 'Player Name',
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      settingsProvider.updatePlayerName(config.player, value);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _PlayerIconField(
                  initialValue: config.icon,
                  label: 'Player Icon',
                  maxLength: 2,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      settingsProvider.updatePlayerIcon(config.player, value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _PlayerNameField extends StatefulWidget {
  final String initialValue;
  final String label;
  final ValueChanged<String> onChanged;

  const _PlayerNameField({
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  @override
  State<_PlayerNameField> createState() => _PlayerNameFieldState();
}

class _PlayerNameFieldState extends State<_PlayerNameField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_PlayerNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha((0.1 * 255).round()),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: widget.onChanged,
    );
  }
}

class _PlayerIconField extends StatefulWidget {
  final String initialValue;
  final String label;
  final int maxLength;
  final ValueChanged<String> onChanged;

  const _PlayerIconField({
    required this.initialValue,
    required this.label,
    required this.maxLength,
    required this.onChanged,
  });

  @override
  State<_PlayerIconField> createState() => _PlayerIconFieldState();
}

class _PlayerIconFieldState extends State<_PlayerIconField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_PlayerIconField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha((0.1 * 255).round()),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 18),
      maxLength: widget.maxLength,
      textAlign: TextAlign.center,
      onChanged: widget.onChanged,
    );
  }
}

extension SettingsScreenHelpers on _SettingsScreenState {
  Widget buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    VoidCallback onToggle,
    IconData icon,
  ) {
    return _buildGlassCard(
      context,
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: (_) => onToggle(),
        secondary: Icon(icon),
      ),
    );
  }

  Widget buildInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return _buildGlassCard(
      context,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    final themeType = Provider.of<SettingsProvider>(context).currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: glassColor,
        border: Border.all(
          color: glassBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).round()),
            blurRadius: 10.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: child,
        ),
      ),
    );
  }
}
