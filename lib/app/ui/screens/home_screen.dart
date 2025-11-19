import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/scores_provider.dart';
import '../../logic/game_logic.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_provider.dart';
import '../theme.dart';
import '../widgets/game_board.dart';
import '../widgets/particles_overlay.dart';
import '../widgets/liquid_components.dart';
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
        final gradientColors = AppTheme.getGradientColors(themeType);
        final glassColor = AppTheme.getGlassColor(themeType);
        final glassBorderColor = AppTheme.getGlassBorderColor(themeType);
        final textColor = AppTheme.getTextColor(themeType);

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
                  filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                  child: Container(color: AppTheme.getBackgroundOverlayColor(themeType)),
                ),
                
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header: Settings & Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TIC TAC TOE",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: 2.0,
                              ),
                            ),
                            _SettingsButton(themeType: themeType),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Scoreboard
                        _Scoreboard(
                          themeType: themeType,
                          settings: settings,
                          scores: scores,
                          activePlayers: settings.activePlayers,
                        ),
                        const SizedBox(height: 20),

                        // Game Mode & Difficulty Selectors
                        if (!game.gameLogic.isGameOver && game.gameLogic.moveHistory.isEmpty) ...[
                           _GameControls(settings: settings, themeType: themeType),
                           const SizedBox(height: 20),
                        ],

                        // Turn Indicator / Status
                        Center(child: _TurnIndicator(game: game, settings: settings, themeType: themeType)),
                        const SizedBox(height: 20),

                        // Game Board
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: LiquidContainer(
                                padding: const EdgeInsets.all(16.0),
                                child: const GameBoard(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

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

class _TurnIndicator extends StatelessWidget {
  final GameProvider game;
  final SettingsProvider settings;
  final AppThemeType themeType;

  const _TurnIndicator({required this.game, required this.settings, required this.themeType});

  @override
  Widget build(BuildContext context) {
    final player = game.gameLogic.currentPlayer;
    final name = settings.getPlayerName(player!);
    final color = settings.getPlayerColor(player);
    final isOver = game.gameLogic.isGameOver;
    final winner = game.gameLogic.winner;
    final glassBorderColor = AppTheme.getGlassBorderColor(themeType);
    final textColor = AppTheme.getTextColor(themeType);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      transitionBuilder: (child, anim) {
        final slide = Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(anim);
        return FadeTransition(opacity: anim, child: SlideTransition(position: slide, child: child));
      },
      child: Container(
        key: ValueKey(isOver ? 'over' : 'turn-${player.index}'),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: AppTheme.getGlassColor(themeType),
          border: Border.all(color: glassBorderColor, width: 1.2),
          boxShadow: [
            if (!isOver) BoxShadow(color: color.withOpacity(0.3), blurRadius: 15.0, spreadRadius: -2.0),
          ]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isOver) ...[
              Text(settings.getPlayerIcon(player), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 10),
              Text("${name.toUpperCase()}'S TURN", style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.0, color: textColor)),
            ] else ...[
              if (winner != null) ...[
                Text(settings.getPlayerIcon(winner), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: settings.getPlayerColor(winner))),
                const SizedBox(width: 10),
                Text("${settings.getPlayerName(winner).toUpperCase()} WINS!", style: TextStyle(fontWeight: FontWeight.w900, color: settings.getPlayerColor(winner), letterSpacing: 1.2, fontSize: 16)),
              ] else ...[
                Icon(Icons.handshake_rounded, color: textColor.withOpacity(0.7)),
                const SizedBox(width: 10),
                Text("DRAW", style: TextStyle(fontWeight: FontWeight.bold, color: textColor.withOpacity(0.7), letterSpacing: 1.0)),
              ]
            ]
          ],
        ),
      ),
    );
  }
}

class _GameControls extends StatelessWidget {
  final SettingsProvider settings;
  final AppThemeType themeType;

  const _GameControls({required this.settings, required this.themeType});

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.getNeonGlowColor(themeType);
    final textColor = AppTheme.getTextColor(themeType);

    return Column(
      children: [
        // Game Mode Selector
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              _buildModeOption(context, GameMode.pvp, "PvP", Icons.people_rounded, activeColor, textColor),
              _buildModeOption(context, GameMode.pve, "PvAI", Icons.smart_toy_rounded, activeColor, textColor),
            ],
          ),
        ),
        
        // Difficulty Selector (Only for PvAI)
        if (settings.gameMode == GameMode.pve) ...[
          const SizedBox(height: 12),
          Container(
            height: 38,
            padding: const EdgeInsets.all(3),
             decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(19),
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

  Widget _buildModeOption(BuildContext context, GameMode mode, String label, IconData icon, Color activeColor, Color textColor) {
    final isSelected = settings.gameMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Micro-interaction: Haptic feedback could go here
          settings.setGameMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected ? Border.all(color: activeColor.withOpacity(0.6)) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? activeColor : textColor.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? activeColor : textColor.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 14)),
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
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected ? Border.all(color: color.withOpacity(0.6)) : null,
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSelected ? color : Colors.white38, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatefulWidget {
  final AppThemeType themeType;
  const _SettingsButton({required this.themeType});
  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _rotation = Tween<double>(begin: 0.0, end: 0.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glassColor = AppTheme.getGlassColor(widget.themeType);
    final borderColor = AppTheme.getGlassBorderColor(widget.themeType);
    final textColor = AppTheme.getTextColor(widget.themeType);

    return RotationTransition(
      turns: _rotation,
      child: InkWell(
        onTap: () {
          _controller.forward().then((_) => _controller.reverse());
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsRootScreen()));
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Icon(Icons.settings_rounded, color: textColor, size: 24),
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
    final glassColor = AppTheme.getGlassColor(themeType);
    final glassBorderColor = AppTheme.getGlassBorderColor(themeType);
    final textColor = AppTheme.getTextColor(themeType);
    final matches = context.watch<GameProvider>().matchHistory;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidAppBar(
        title: 'Match History',
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
           gradient: LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: AppTheme.getGradientColors(themeType),
           ),
        ),
        child: SafeArea(
          child: matches.isEmpty 
            ? Center(child: Text("No matches yet", style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 18)))
            : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = matches[i];
                final winnerName = m.winner != null ? settings.getPlayerName(m.winner!) : 'Draw';
                final winnerColor = m.winner != null ? settings.getPlayerColor(m.winner!) : textColor.withOpacity(0.7);
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: glassColor,
                    border: Border.all(color: glassBorderColor, width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: winnerColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.emoji_events_rounded, color: winnerColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(winnerName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('${m.boardSize}x${m.boardSize} • Win ${m.winCondition}', style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('${m.moveCount} moves', style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14)),
                    ],
                  ),
                );
              },
            ),
        ),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  final AppThemeType themeType;
  final SettingsProvider settings;
  final ScoresProvider scores;
  final List<Player> activePlayers;
  const _Scoreboard({required this.themeType, required this.settings, required this.scores, required this.activePlayers});
  @override
  Widget build(BuildContext context) {
    final glassBorderColor = AppTheme.getGlassBorderColor(themeType);
    final textColor = AppTheme.getTextColor(themeType);
    final players = activePlayers;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: players.map((p) {
        final color = settings.getPlayerColor(p);
        final winCount = scores.wins[p] ?? 0;
        final isActive = activePlayers.contains(p);
        
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: AppTheme.getGlassColor(themeType),
              border: Border.all(
                color: isActive ? color.withOpacity(0.5) : glassBorderColor,
                width: isActive ? 2 : 1,
              ),
              boxShadow: [
                if (isActive) BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, spreadRadius: 1),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 40, 
                  height: 40, 
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2), 
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.6), width: 2),
                  ),
                  child: Center(child: Text(settings.getPlayerIcon(p), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20))),
                ),
                const SizedBox(height: 8),
                Text(
                  settings.getPlayerName(p),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: textColor.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Text(
                    '$winCount',
                    key: ValueKey('wins-$p-$winCount'),
                    style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final AppThemeType themeType;
  final VoidCallback onUndo;
  final VoidCallback onRestart;
  final VoidCallback onHistory;
  const _BottomActions({required this.themeType, required this.onUndo, required this.onRestart, required this.onHistory});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LiquidButton(label: 'Undo', icon: Icons.undo_rounded, onTap: onUndo),
        const SizedBox(width: 16),
        LiquidButton(label: 'Restart', icon: Icons.refresh_rounded, onTap: onRestart, isPrimary: true),
        const SizedBox(width: 16),
        LiquidButton(label: 'History', icon: Icons.history_rounded, onTap: onHistory),
      ],
    );
  }
}