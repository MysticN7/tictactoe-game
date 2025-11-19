import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/scores_provider.dart';
import '../../logic/game_logic.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_provider.dart';
import '../theme.dart' as theme;
import '../widgets/game_board.dart';
import '../widgets/particles_overlay.dart';
import 'settings_root_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ParticlesController _confetti = ParticlesController();
  int _lastHistorySize = 0;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SettingsProvider, ScoresProvider, GameProvider>(
      builder: (context, settings, scores, game, _) {
        final themeType = settings.currentTheme.toAppThemeType();
        final gradientColors = theme.AppTheme.getGradientColors(themeType);
        final glassColor = theme.AppTheme.getGlassColor(themeType);
        final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);

        if (settings.isConfettiEnabled && game.matchHistory.length > _lastHistorySize) {
          if (game.matchHistory.isNotEmpty && game.matchHistory.first.winner != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
          }
          _lastHistorySize = game.matchHistory.length;
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
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
                // Background Overlay
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                  child: Container(color: theme.AppTheme.getBackgroundOverlayColor(themeType)),
                ),
                
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header / Scoreboard
                        _Scoreboard(
                          themeType: themeType,
                          settings: settings,
                          scores: scores,
                          activePlayers: settings.activePlayers,
                        ),
                        const SizedBox(height: 16),

                        // Game Mode & Difficulty Selectors (Only if game not in progress or just started)
                        if (!game.gameLogic.isGameOver && game.gameLogic.moveHistory.isEmpty) ...[
                           _GameControls(settings: settings, themeType: themeType),
                           const SizedBox(height: 16),
                        ],

                        // Turn Indicator / Status
                        Consumer<GameProvider>(
                          builder: (context, game, _) {
                            final player = game.gameLogic.currentPlayer;
                            final name = context.read<SettingsProvider>().getPlayerName(player!);
                            final color = context.read<SettingsProvider>().getPlayerColor(player);
                            final isOver = game.gameLogic.isGameOver;
                            final winner = game.gameLogic.winner;
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              transitionBuilder: (child, anim) {
                                final slide = Tween<Offset>(begin: const Offset(0, -0.06), end: Offset.zero).animate(anim);
                                return FadeTransition(opacity: anim, child: SlideTransition(position: slide, child: child));
                              },
                              child: Container(
                                key: ValueKey(isOver ? 'over' : 'turn-${player.index}'),
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: theme.AppTheme.getGlassSurfaceColors(themeType)),
                                  border: Border.all(color: glassBorderColor, width: 1.2),
                                  boxShadow: [
                                    BoxShadow(color: color.withAlpha(40), blurRadius: 12.0, spreadRadius: -2.0),
                                  ]
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isOver) ...[
                                      Text(context.read<SettingsProvider>().getPlayerIcon(player), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                                      const SizedBox(width: 10),
                                      Text("${name.toUpperCase()}'s Turn", style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                    ] else ...[
                                      if (winner != null) ...[
                                        Text(context.read<SettingsProvider>().getPlayerIcon(winner), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.read<SettingsProvider>().getPlayerColor(winner))),
                                        const SizedBox(width: 10),
                                        Text("${context.read<SettingsProvider>().getPlayerName(winner).toUpperCase()} WINS", style: TextStyle(fontWeight: FontWeight.bold, color: context.read<SettingsProvider>().getPlayerColor(winner), letterSpacing: 1.0)),
                                      ] else ...[
                                        const Icon(Icons.handshake_rounded, color: Colors.white70),
                                        const SizedBox(width: 10),
                                        const Text("DRAW", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.0)),
                                      ]
                                    ]
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Game Board
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: _GlassCard(
                                glassColor: glassColor,
                                glassBorderColor: glassBorderColor,
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: GameBoard(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Bottom Actions
                        _BottomActions(
                          themeType: themeType,
                          onUndo: () => context.read<GameProvider>().undoLastMove(),
                          onRestart: () => context.read<GameProvider>().resetGame(),
                          onHistory: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Settings Button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _SettingsButton(
                        themeType: themeType,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsRootScreen()),
                        ),
                      ),
                    ),
                  ),
                ),

                // Confetti Overlay
                Consumer<SettingsProvider>(
                  builder: (context, s, _) => ParticlesOverlay(controller: _confetti, enabled: s.isConfettiEnabled),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GameControls extends StatelessWidget {
  final SettingsProvider settings;
  final theme.AppThemeType themeType;

  const _GameControls({required this.settings, required this.themeType});

  @override
  Widget build(BuildContext context) {
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final activeColor = theme.AppTheme.getNeonGlowColor(themeType);

    return Column(
      children: [
        // Game Mode Selector
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: glassBorderColor.withAlpha(50)),
          ),
          child: Row(
            children: [
              _buildModeOption(context, GameMode.pvp, "PvP", Icons.people_rounded, activeColor),
              _buildModeOption(context, GameMode.pve, "PvAI", Icons.smart_toy_rounded, activeColor),
            ],
          ),
        ),
        
        // Difficulty Selector (Only for PvAI)
        if (settings.gameMode == GameMode.pve) ...[
          const SizedBox(height: 10),
          Container(
            height: 36,
             decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: glassBorderColor.withAlpha(50)),
            ),
            child: Row(
              children: [
                _buildDiffOption(context, AIDifficulty.easy, "Easy", Colors.greenAccent),
                _buildDiffOption(context, AIDifficulty.medium, "Med", Colors.amberAccent),
                _buildDiffOption(context, AIDifficulty.hard, "Hard", Colors.orangeAccent),
                _buildDiffOption(context, AIDifficulty.impossible, "Imp", Colors.redAccent),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModeOption(BuildContext context, GameMode mode, String label, IconData icon, Color activeColor) {
    final isSelected = settings.gameMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => settings.setGameMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withAlpha(50) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected ? Border.all(color: activeColor.withAlpha(150)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? activeColor : Colors.white60),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: isSelected ? activeColor : Colors.white60, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiffOption(BuildContext context, AIDifficulty diff, String label, Color color) {
    final isSelected = settings.aiDifficulty == diff;
    return Expanded(
      child: GestureDetector(
        onTap: () => settings.setAIDifficulty(diff),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(40) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: color.withAlpha(120)) : null,
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSelected ? color : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 11)),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Color glassColor;
  final Color glassBorderColor;
  final Widget child;
  const _GlassCard({required this.glassColor, required this.glassBorderColor, required this.child});
  @override
  Widget build(BuildContext context) {
    final themeType = context.read<SettingsProvider>().currentTheme.toAppThemeType();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.AppTheme.getGlassSurfaceColors(themeType),
        ),
        border: Border.all(color: glassBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.2 * 255).round()), blurRadius: 25.0, spreadRadius: 0, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: child,
        ),
      ),
    );
  }
}

class _SettingsButton extends StatefulWidget {
  final theme.AppThemeType themeType;
  final VoidCallback onTap;
  const _SettingsButton({required this.themeType, required this.onTap});
  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _rotation;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rotation = Tween<double>(begin: 0.0, end: 0.15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final glassColor = theme.AppTheme.getGlassColor(widget.themeType);
    final borderColor = theme.AppTheme.getGlassBorderColor(widget.themeType);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ScaleTransition(
        scale: _scale,
        child: RotationTransition(
          turns: _rotation,
          child: InkWell(
            onTap: _press,
            borderRadius: BorderRadius.circular(20),
            splashColor: borderColor.withAlpha((0.25 * 255).round()),
            highlightColor: Colors.transparent,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: glassColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1.6),
                boxShadow: [
                  BoxShadow(color: borderColor.withAlpha(_hover ? 120 : 70), blurRadius: _hover ? 14.0 : 10.0, spreadRadius: 0.8),
                ],
              ),
              child: const Icon(Icons.settings_rounded, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final matches = context.watch<GameProvider>().matchHistory;
    return Scaffold(
      appBar: AppBar(title: const Text('Match History'), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
           gradient: LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: theme.AppTheme.getGradientColors(themeType),
           ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final m = matches[i];
                final winnerName = m.winner != null ? settings.getPlayerName(m.winner!) : 'Draw';
                final winnerColor = m.winner != null ? settings.getPlayerColor(m.winner!) : Colors.white70;
                return Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: glassColor,
                    border: Border.all(color: glassBorderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: winnerColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${m.boardSize}x${m.boardSize}, win ${m.winCondition} • $winnerName')),
                      Text('${m.moveCount} moves'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  final theme.AppThemeType themeType;
  final SettingsProvider settings;
  final ScoresProvider scores;
  final List<Player> activePlayers;
  const _Scoreboard({required this.themeType, required this.settings, required this.scores, required this.activePlayers});
  @override
  Widget build(BuildContext context) {
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final players = activePlayers;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final perItem = width / (players.isNotEmpty ? players.length : 1);
        final scale = (perItem / 160.0).clamp(0.9, 1.8);
        final marginH = 6.0 * scale;
        final padV = 12.0 * scale;
        final padH = 14.0 * scale;
        final radius = 16.0 * scale;
        final circle = 12.0 * scale;
        final gap = 8.0 * scale;
        final symbolFont = 18.0 * scale;
        final countFont = 22.0 * scale;
        final blurActive = (12.0 * scale).clamp(8.0, 16.0);
        final blurInactive = (8.0 * scale).clamp(6.0, 12.0);
        final borderWidth = (1.8 * scale).clamp(1.6, 2.4);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: players.map((p) {
            final color = settings.getPlayerColor(p);
            final winCount = scores.wins[p] ?? 0;
            final isActive = activePlayers.contains(p);
            return Expanded(
              child: AnimatedContainer(
                margin: EdgeInsets.symmetric(horizontal: marginH),
                padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.AppTheme.getGlassSurfaceColors(themeType),
                  ),
                  border: Border.all(
                    color: isActive ? glassBorderColor : glassBorderColor.withAlpha((0.4 * 255).round()),
                    width: borderWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha((isActive ? 90 : 35)),
                      blurRadius: isActive ? blurActive : blurInactive,
                      spreadRadius: 0.8,
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 240),
                child: Row(
                  children: [
                    Container(width: circle, height: circle, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withAlpha(150), blurRadius: 8)])),
                    SizedBox(width: gap),
                    Expanded(
                      child: Text(
                        settings.getPlayerIcon(p),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: symbolFont, shadows: [Shadow(color: color.withAlpha(150), blurRadius: 8)]),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Text(
                        '$winCount',
                        key: ValueKey('wins-$p-$winCount'),
                        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: countFont),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _BottomActions extends StatelessWidget {
  final theme.AppThemeType themeType;
  final VoidCallback onUndo;
  final VoidCallback onRestart;
  final VoidCallback onHistory;
  const _BottomActions({required this.themeType, required this.onUndo, required this.onRestart, required this.onHistory});
  @override
  Widget build(BuildContext context) {
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final actionColors = theme.AppTheme.getGlassSurfaceColors(themeType);
    Widget buildButton(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: _ActionButton(
          gradientColors: actionColors,
          borderColor: glassBorderColor,
          icon: icon,
          label: label,
          onTap: onTap,
        ),
      );
    }
    return Row(
      children: [
        buildButton(Icons.undo_rounded, 'Undo', onUndo),
        const SizedBox(width: 12),
        buildButton(Icons.restart_alt_rounded, 'Restart', onRestart),
        const SizedBox(width: 12),
        buildButton(Icons.history_rounded, 'History', onHistory),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final List<Color> gradientColors;
  final Color borderColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.gradientColors, required this.borderColor, required this.icon, required this.label, required this.onTap});
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _hover = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _press() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: _press,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.gradientColors),
              border: Border.all(color: widget.borderColor, width: _hover ? 2.0 : 1.6),
              boxShadow: [
                BoxShadow(color: widget.borderColor.withAlpha(_hover ? 130 : 90), blurRadius: _hover ? 14.0 : 10.0, spreadRadius: 0.9),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white),
                // const SizedBox(width: 10),
                // Text(widget.label, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}