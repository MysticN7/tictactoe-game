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
                  child: Container(color: Colors.black.withOpacity(0.2)),
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
                                _buildSwitchTile(
                                  context,
                                  'Sound',
                                  settingsProvider.isSoundEnabled,
                                  () => settingsProvider.toggleSound(),
                                  Icons.volume_up,
                                ),
                                _buildSwitchTile(
                                  context,
                                  'Vibration',
                                  settingsProvider.isVibrationEnabled,
                                  () => settingsProvider.toggleVibration(),
                                  Icons.vibration,
                                ),
                              ],
                            ),
                            _buildSection(
                              context,
                              'About',
                              [
                                _buildInfoTile(
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
            max: 10,
            divisions: 7,
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
    return _buildGlassCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Player Mode'),
          ),
          RadioListTile<List<Player>>(
            title: const Text('2 Players (X, O)'),
            value: [Player.x, Player.o],
            groupValue: settingsProvider.activePlayers,
            onChanged: (value) {
              if (value != null) {
                settingsProvider.setActivePlayers(value);
                Provider.of<GameProvider>(context, listen: false).resetGame();
              }
            },
          ),
          RadioListTile<List<Player>>(
            title: const Text('3 Players (X, O, △)'),
            value: [Player.x, Player.o, Player.triangle],
            groupValue: settingsProvider.activePlayers,
            onChanged: (value) {
              if (value != null) {
                settingsProvider.setActivePlayers(value);
                Provider.of<GameProvider>(context, listen: false).resetGame();
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlayerCustomization(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    return settingsProvider.playerConfigs.map((config) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildGlassCard(
          context,
          child: Column(
            children: [
              ListTile(
                title: Text(config.name),
                subtitle: Text('Icon: ${config.icon}'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: config.name),
                  onSubmitted: (value) {
                    settingsProvider.updatePlayerName(config.player, value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Player Icon',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: config.icon),
                  maxLength: 2,
                  onSubmitted: (value) {
                    settingsProvider.updatePlayerIcon(config.player, value);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSwitchTile(
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

  Widget _buildInfoTile(
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
            color: Colors.black.withOpacity(0.2),
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
