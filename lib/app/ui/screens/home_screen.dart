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
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(color: theme.AppTheme.getBackgroundOverlayColor(themeType)),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _Scoreboard(
                                themeType: themeType,
                                settings: settings,
                                scores: scores,
                                activePlayers: settings.activePlayers,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SettingsRootScreen()),
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: glassColor,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: glassBorderColor, width: 1.5),
                                ),
                                child: const Icon(Icons.settings_rounded, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Consumer<GameProvider>(
                          builder: (context, game, _) {
                            final player = game.gameLogic.currentPlayer;
                            final name = context.read<SettingsProvider>().getPlayerName(player!);
                            final color = context.read<SettingsProvider>().getPlayerColor(player);
                            return Container(
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: glassColor,
                                border: Border.all(color: glassBorderColor, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.read<SettingsProvider>().getPlayerIcon(player),
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("${name.toUpperCase()}'s Turn"),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _GlassCard(
                            glassColor: glassColor,
                            glassBorderColor: glassBorderColor,
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: GameBoard(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
          BoxShadow(color: Colors.black.withAlpha((0.1 * 255).round()), blurRadius: 20.0, spreadRadius: 0, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: child,
        ),
      ),
    );
  }
}

// Removed main menu button UI per redesign

// Play screen merged into HomeScreen

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
      appBar: AppBar(title: const Text('Match History')),
      body: Padding(
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
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final players = Player.values;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: players.map((p) {
        final name = settings.getPlayerName(p);
        final color = settings.getPlayerColor(p);
        final winCount = scores.wins[p] ?? 0;
        final isActive = activePlayers.contains(p);
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: isActive ? glassColor : glassColor.withAlpha((0.12 * 255).round()),
              border: Border.all(color: isActive ? glassBorderColor : glassBorderColor.withAlpha((0.4 * 255).round()), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(color: Colors.white)),
                const Spacer(),
                Text('$winCount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        );
      }).toList(),
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
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    Widget buildButton(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: glassColor,
              border: Border.all(color: glassBorderColor, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        buildButton(Icons.undo_rounded, 'Undo', onUndo),
        const SizedBox(width: 10),
        buildButton(Icons.restart_alt_rounded, 'Restart', onRestart),
        const SizedBox(width: 10),
        buildButton(Icons.history_rounded, 'History', onHistory),
      ],
    );
  }
}