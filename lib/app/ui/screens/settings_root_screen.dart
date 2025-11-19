import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
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
                  filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                  child: Container(color: Colors.black.withOpacity(0.2)),
                ),
                SafeArea(
                  bottom: false,
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
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: _LiquidNavigationBar(
                    themeType: themeType,
                    selectedIndex: _index,
                    onChanged: (i) => setState(() => _index = i),
                    destinations: const [
                      _NavItem(icon: Icons.grid_view_rounded, label: 'Game'),
                      _NavItem(icon: Icons.people_alt_rounded, label: 'Players'),
                      _NavItem(icon: Icons.graphic_eq_rounded, label: 'Audio'),
                      _NavItem(icon: Icons.palette_rounded, label: 'Theme'),
                      _NavItem(icon: Icons.info_outline_rounded, label: 'About'),
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
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _LiquidNavigationBar extends StatelessWidget {
  final theme.AppThemeType themeType;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<_NavItem> destinations;

  const _LiquidNavigationBar({
    required this.themeType,
    required this.selectedIndex,
    required this.onChanged,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final borderColor = theme.AppTheme.getGlassBorderColor(themeType);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: glassColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(destinations.length, (index) {
              final item = destinations[index];
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  padding: EdgeInsets.all(isSelected ? 12 : 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                    size: isSelected ? 28 : 24,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
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
          colors: theme.AppTheme.getGlassSurfaceColors(themeType),
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
      padding: const EdgeInsets.only(bottom: 100),
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? glassBorderColor : glassBorderColor.withOpacity(0.3),
                            width: isSelected ? 2.0 : 1.5,
                          ),
                        ),
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
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? glassBorderColor : glassBorderColor.withOpacity(0.3),
                            width: isSelected ? 2.0 : 1.5,
                          ),
                        ),
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
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _DynamicTip(boardSize: settings.boardSize, winCondition: settings.winCondition),
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
                      child: const Icon(Icons.people_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Game Mode',
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
              const SizedBox(height: 20),
            ],
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
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: selected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: selected ? glassBorderColor : glassBorderColor.withOpacity(0.3),
            width: selected ? 2.0 : 1.5,
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Players', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  title: Text(config.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('${config.player.toString().split('.').last.toUpperCase()} Player', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Player Name', labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white.withOpacity(0.1)),
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
                    decoration: InputDecoration(labelText: 'Player Icon', labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white.withOpacity(0.1)),
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
      padding: const EdgeInsets.only(bottom: 100),
      children: [
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Audio & Haptics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      _GlassCard(child: SwitchListTile(title: const Text('Sound', style: TextStyle(color: Colors.white)), value: settings.isSoundEnabled, onChanged: (_) => settings.toggleSound(), secondary: const Icon(Icons.volume_up, color: Colors.white))),
      _GlassCard(child: SwitchListTile(title: const Text('Vibration', style: TextStyle(color: Colors.white)), value: settings.isVibrationEnabled, onChanged: (_) => settings.toggleVibration(), secondary: const Icon(Icons.vibration, color: Colors.white))),
      _GlassCard(child: SwitchListTile(title: const Text('Confetti', style: TextStyle(color: Colors.white)), value: settings.isConfettiEnabled, onChanged: (_) => settings.toggleConfetti(), secondary: const Icon(Icons.celebration, color: Colors.white))),
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
      padding: const EdgeInsets.only(bottom: 100),
      children: [
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Appearance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      _GlassCard(child: Column(children: [
        _ThemeOption(name: 'Glassmorphism', themeMode: GameThemeMode.glassmorphism, selected: settings.currentTheme == GameThemeMode.glassmorphism, onTap: () => settings.setTheme(GameThemeMode.glassmorphism)),
        const Divider(color: Colors.white24),
        _ThemeOption(name: 'Liquid Glass', themeMode: GameThemeMode.liquidGlass, selected: settings.currentTheme == GameThemeMode.liquidGlass, onTap: () => settings.setTheme(GameThemeMode.liquidGlass)),
        const Divider(color: Colors.white24),
        _ThemeOption(name: 'Neon Glass', themeMode: GameThemeMode.neonGlass, selected: settings.currentTheme == GameThemeMode.neonGlass, onTap: () => settings.setTheme(GameThemeMode.neonGlass)),
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
    return ListTile(
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: Colors.cyanAccent) : null,
      onTap: onTap,
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('About', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        _GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Tic Tac Toe 3 Player', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Version 1.0.0', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                const Text('A premium Tic Tac Toe experience with 3-player support and beautiful glassmorphism themes.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => launchUrl(Uri.parse('https://github.com/yourusername/tictactoe_3_player')),
                  icon: const Icon(Icons.code),
                  label: const Text('View Source Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _DynamicTip extends StatelessWidget {
  final int boardSize;
  final int winCondition;

  const _DynamicTip({super.key, required this.boardSize, required this.winCondition});

  @override
  Widget build(BuildContext context) {
    String tip = "";
    Color color = Colors.white70;
    IconData icon = Icons.lightbulb_outline_rounded;

    if (winCondition > boardSize) {
      tip = "Impossible! Win condition cannot be larger than board size.";
      color = const Color(0xFFFF5252);
      icon = Icons.warning_amber_rounded;
    } else if (boardSize == 3 && winCondition == 3) {
      tip = "Classic Tic-Tac-Toe. Perfect for quick matches.";
      color = const Color(0xFF69F0AE);
    } else if (boardSize == 4) {
      if (winCondition == 3) {
         tip = "Easier to win on a larger board. Good for beginners.";
      } else {
         tip = "Standard 4x4 challenge. Strategic play required.";
      }
    } else if (boardSize == 5) {
      if (winCondition == 3) {
        tip = "Very easy to win. Expect fast rounds!";
      } else if (winCondition == 4) {
        tip = "Balanced for 5x5. Great for 3 players.";
        color = const Color(0xFF69F0AE);
      } else {
        tip = "Hardcore mode! Block your opponents carefully.";
        color = const Color(0xFFFF4081);
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}