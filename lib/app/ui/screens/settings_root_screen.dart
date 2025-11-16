import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_provider.dart';
import '../theme.dart' as theme;
import '../../logic/game_logic.dart';

class SettingsRootScreen extends StatefulWidget {
  const SettingsRootScreen({super.key});

  @override
  State<SettingsRootScreen> createState() => _SettingsRootScreenState();
}

class _SettingsRootScreenState extends State<SettingsRootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final themeType = settings.currentTheme.toAppThemeType();
        final gradientColors = theme.AppTheme.getGradientColors(themeType);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
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
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
                SafeArea(
                  child: RepaintBoundary(
                    child: IndexedStack(
                      index: _index,
                      children: const [
                        _GameSettingsPage(),
                        _PlayersPage(),
                        _AudioHapticsPage(),
                        _AppearancePage(),
                        _AboutPage(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.AppTheme.getGlassColor(themeType),
              border: Border(
                top: BorderSide(
                  color: theme.AppTheme.getGlassBorderColor(themeType),
                  width: 1.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: theme.AppTheme.getNeonGlowColor(themeType).withOpacity(
                    themeType == theme.AppThemeType.liquidGlow ? 0.22 : 0.16,
                  ),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.grid_on), label: 'Game'),
                    NavigationDestination(icon: Icon(Icons.person), label: 'Players'),
                    NavigationDestination(icon: Icon(Icons.volume_up), label: 'Audio'),
                    NavigationDestination(icon: Icon(Icons.palette), label: 'Theme'),
                    NavigationDestination(icon: Icon(Icons.info), label: 'About'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final themeType = settings.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            glassColor,
            glassColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: glassBorderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.0,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: child,
        ),
      ),
    );
  }
}

class _GameSettingsPage extends StatelessWidget {
  const _GameSettingsPage();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Game Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: glassColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: glassBorderColor.withOpacity(0.5), width: 1.5),
                      ),
                      child: const Icon(Icons.grid_on_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Board Size',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [3, 4, 5].map((size) {
                    final isSelected = settings.boardSize == size;
                    return GestureDetector(
                      onTap: () {
                        settings.setBoardSize(size);
                        context.read<GameProvider>().resetGame();
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected
                                ? [
                                    glassBorderColor.withOpacity(0.4),
                                    glassBorderColor.withOpacity(0.2),
                                  ]
                                : [
                                    glassColor.withOpacity(0.3),
                                    glassColor.withOpacity(0.1),
                                  ],
                          ),
                          border: Border.all(
                            color: isSelected
                                ? glassBorderColor
                                : glassBorderColor.withOpacity(0.3),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: glassBorderColor.withOpacity(0.4),
                                    blurRadius: 12.0,
                                    spreadRadius: 2.0,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$size',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    '×$size',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected ? Colors.white70 : Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: glassColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: glassBorderColor.withOpacity(0.5), width: 1.5),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Win Condition',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [3, 4, 5].map((value) {
                    final isSelected = settings.winCondition == value;
                    return GestureDetector(
                      onTap: () {
                        settings.setWinCondition(value);
                        context.read<GameProvider>().resetGame();
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isSelected
                                ? [
                                    glassBorderColor.withOpacity(0.4),
                                    glassBorderColor.withOpacity(0.2),
                                  ]
                                : [
                                    glassColor.withOpacity(0.3),
                                    glassColor.withOpacity(0.1),
                                  ],
                          ),
                          border: Border.all(
                            color: isSelected
                                ? glassBorderColor
                                : glassBorderColor.withOpacity(0.3),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: glassBorderColor.withOpacity(0.4),
                                    blurRadius: 12.0,
                                    spreadRadius: 2.0,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$value',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'in a row',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected ? Colors.white70 : Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        _GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    title: '2 Players',
                    icons: 'X  O',
                    selected: settings.activePlayers.length == 2,
                    onTap: () {
                      settings.setActivePlayers([Player.x, Player.o]);
                      context.read<GameProvider>().resetGame();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeButton(
                    title: '3 Players',
                    icons: 'X  O  △',
                    selected: settings.activePlayers.length == 3,
                    onTap: () {
                      settings.setActivePlayers([Player.x, Player.o, Player.triangle]);
                      context.read<GameProvider>().resetGame();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String icons;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({required this.title, required this.icons, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final themeType = settings.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [
                    glassBorderColor.withOpacity(0.4),
                    glassBorderColor.withOpacity(0.2),
                  ]
                : [
                    glassColor.withOpacity(0.3),
                    glassColor.withOpacity(0.1),
                  ],
          ),
          border: Border.all(
            color: selected ? glassBorderColor : glassBorderColor.withOpacity(0.3),
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: glassBorderColor.withOpacity(0.4),
                    blurRadius: 12.0,
                    spreadRadius: 2.0,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  icons,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                    color: selected ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayersPage extends StatefulWidget {
  const _PlayersPage();
  @override
  State<_PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<_PlayersPage> {
  final Map<Player, TextEditingController> _nameControllers = {};
  final Map<Player, TextEditingController> _iconControllers = {};

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    for (final config in settings.playerConfigs) {
      _nameControllers[config.player] = TextEditingController(text: config.name);
      _iconControllers[config.player] = TextEditingController(text: config.icon);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    for (final config in settings.playerConfigs) {
      if (!_nameControllers.containsKey(config.player)) {
        _nameControllers[config.player] = TextEditingController(text: config.name);
      } else if (_nameControllers[config.player]!.text != config.name) {
        _nameControllers[config.player]!.text = config.name;
      }
      if (!_iconControllers.containsKey(config.player)) {
        _iconControllers[config.player] = TextEditingController(text: config.icon);
      } else if (_iconControllers[config.player]!.text != config.icon) {
        _iconControllers[config.player]!.text = config.icon;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    for (final controller in _iconControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Players', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        ...settings.playerConfigs.map((config) {
          final color = settings.getPlayerColor(config.player);
          final nameController = _nameControllers[config.player] ?? TextEditingController(text: config.name);
          final iconController = _iconControllers[config.player] ?? TextEditingController(text: config.icon);
          return _GlassCard(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: color, width: 2)),
                    child: Center(child: Text(config.icon, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))),
                  ),
                  title: Text(config.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${config.player.toString().split('.').last.toUpperCase()} Player'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Player Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white.withOpacity(0.1)),
                    style: const TextStyle(color: Colors.white),
                    controller: nameController,
                    onChanged: (v) {
                      if (v.isNotEmpty) {
                        settings.updatePlayerName(config.player, v);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Player Icon', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white.withOpacity(0.1)),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    controller: iconController,
                    maxLength: 2,
                    textAlign: TextAlign.center,
                    onChanged: (v) {
                      if (v.isNotEmpty) {
                        settings.updatePlayerIcon(config.player, v);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _AudioHapticsPage extends StatelessWidget {
  const _AudioHapticsPage();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Audio & Haptics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      _GlassCard(child: SwitchListTile(title: const Text('Sound'), value: settings.isSoundEnabled, onChanged: (_) => settings.toggleSound(), secondary: const Icon(Icons.volume_up))),
      _GlassCard(child: SwitchListTile(title: const Text('Vibration'), value: settings.isVibrationEnabled, onChanged: (_) => settings.toggleVibration(), secondary: const Icon(Icons.vibration))),
      _GlassCard(child: SwitchListTile(title: const Text('Confetti'), value: settings.isConfettiEnabled, onChanged: (_) => settings.toggleConfetti(), secondary: const Icon(Icons.celebration))),
    ]);
  }
}

class _AppearancePage extends StatelessWidget {
  const _AppearancePage();
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Appearance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      _GlassCard(child: Column(children: [
        _ThemeOption(name: 'Light', themeMode: GameThemeMode.light, selected: settings.currentTheme == GameThemeMode.light, onTap: () => settings.setTheme(GameThemeMode.light)),
        const Divider(),
        _ThemeOption(name: 'Dark', themeMode: GameThemeMode.dark, selected: settings.currentTheme == GameThemeMode.dark, onTap: () => settings.setTheme(GameThemeMode.dark)),
        const Divider(),
        _ThemeOption(name: 'Liquid Glow', themeMode: GameThemeMode.liquidGlow, selected: settings.currentTheme == GameThemeMode.liquidGlow, onTap: () => settings.setTheme(GameThemeMode.liquidGlow)),
      ])),
    ]);
  }
}

class _ThemeOption extends StatelessWidget {
  final String name;
  final GameThemeMode themeMode;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeOption({required this.name, required this.themeMode, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(name), trailing: selected ? const Icon(Icons.check, color: Colors.green) : null, onTap: onTap);
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('About', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      _GlassCard(
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.grid_on_rounded, color: Colors.blue),
              title: Text('Customizable Board', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('3x3, 4x4, or 5x5 board sizes'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.palette_rounded, color: Colors.purple),
              title: Text('Multiple Themes', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Light, Dark, and Liquid Glow'),
            ),
          ],
        ),
      ),
    ]);
  }
}