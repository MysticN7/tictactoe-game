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
import 'tournament_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ParticlesController _confetti = ParticlesController();
  int _lastHistorySize = 0;
  bool _isPlaying = false;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _startGame(VoidCallback startMethod) {
    startMethod();
    setState(() {
      _isPlaying = true;
    });
  }

  void _exitGame() {
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SettingsProvider, ScoresProvider, GameProvider>(
      builder: (context, settings, scores, game, _) {
        final themeType = settings.currentTheme.toAppThemeType();
        final gradientColors = AppTheme.getGradientColors(themeType);
        final textColor = AppTheme.getTextColor(themeType);

        // Confetti Logic
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
                    child: _isPlaying 
                      ? _buildGameView(context, settings, scores, game, themeType, textColor)
                      : _buildMainMenu(context, settings, game, themeType, textColor),
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

  Widget _buildMainMenu(BuildContext context, SettingsProvider settings, GameProvider game, AppThemeType themeType, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _SettingsButton(themeType: themeType),
          ],
        ),
        const Spacer(flex: 1),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.getGlassColor(themeType),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.getGlassBorderColor(themeType), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.getNeonGlowColor(themeType).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(Icons.grid_4x4_rounded, size: 60, color: AppTheme.getNeonGlowColor(themeType)),
              ),
              const SizedBox(height: 24),
              Text(
                "TIC TAC TOE",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(
                      color: AppTheme.getNeonGlowColor(themeType).withOpacity(0.5),
                      blurRadius: 20,
                    )
                  ],
                ),
              ),
              Text(
                "ULTIMATE",
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                  letterSpacing: 8.0,
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
        _MenuButton(
          label: "LOCAL PvP",
          icon: Icons.people_rounded,
          themeType: themeType,
          onTap: () => _startGame(() => game.startPvP()),
        ),
        const SizedBox(height: 16),
        _MenuButton(
          label: "VS AI",
          icon: Icons.smart_toy_rounded,
          themeType: themeType,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _DifficultyDialog(
                themeType: themeType,
                onSelect: (difficulty) {
                  Navigator.pop(context);
                  _startGame(() => game.startPvAI(difficulty));
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _MenuButton(
          label: "TOURNAMENT",
          icon: Icons.emoji_events_rounded,
          themeType: themeType,
          isSpecial: true,
          onTap: () {
             // For tournament, we might want to push a dedicated screen instead of just setting _isPlaying
             // But for now, let's use the _isPlaying flow and maybe show TournamentScreen content
             // Actually, the user requested a dedicated TournamentScreen.
             // So let's push that screen.
             game.startTournament();
             Navigator.of(context).push(
               MaterialPageRoute(builder: (_) => const TournamentScreen()),
             );
          },
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildGameView(BuildContext context, SettingsProvider settings, ScoresProvider scores, GameProvider game, AppThemeType themeType, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
              onPressed: _exitGame,
            ),
            if (game.isAiThinking)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getNeonGlowColor(themeType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.getNeonGlowColor(themeType).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 12, 
                      height: 12, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: textColor)
                    ),
                    const SizedBox(width: 8),
                    Text("AI Thinking...", style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
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
          onUndo: () => game.undoLastMove(),
          onRestart: () => game.resetGame(),
          onHistory: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppThemeType themeType;
  final VoidCallback onTap;
  final bool isSpecial;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.themeType,
    required this.onTap,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final glassColor = AppTheme.getGlassColor(themeType);
    final borderColor = AppTheme.getGlassBorderColor(themeType);
    final textColor = AppTheme.getTextColor(themeType);
    final glowColor = AppTheme.getNeonGlowColor(themeType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isSpecial ? glowColor.withOpacity(0.2) : glassColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSpecial ? glowColor : borderColor,
            width: isSpecial ? 2 : 1,
          ),
          boxShadow: [
            if (isSpecial)
              BoxShadow(
                color: glowColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSpecial ? glowColor : textColor, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSpecial ? glowColor : textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyDialog extends StatelessWidget {
  final AppThemeType themeType;
  final Function(AIDifficulty) onSelect;

  const _DifficultyDialog({required this.themeType, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final glassColor = AppTheme.getGlassColor(themeType);
    final textColor = AppTheme.getTextColor(themeType);

    return AlertDialog(
      backgroundColor: glassColor.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Select Difficulty', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AIDifficulty.values.map((d) {
          return ListTile(
            title: Text(d.name.toUpperCase(), style: TextStyle(color: textColor)),
            onTap: () => onSelect(d),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            hoverColor: Colors.white10,
          );
        }).toList(),
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

class _BottomActions extends StatefulWidget {
  final AppThemeType themeType;
  final VoidCallback onUndo;
  final VoidCallback onRestart;
  final VoidCallback onHistory;

  const _BottomActions({
    required this.themeType,
    required this.onUndo,
    required this.onRestart,
    required this.onHistory,
  });

  @override
  State<_BottomActions> createState() => _BottomActionsState();
}

class _BottomActionsState extends State<_BottomActions> with SingleTickerProviderStateMixin {
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.undo_rounded,
          label: 'Undo',
          onTap: widget.onUndo,
          glassColor: glassColor,
          borderColor: borderColor,
          textColor: textColor,
        ),
        _buildActionButton(
          icon: Icons.refresh_rounded,
          label: 'Restart',
          onTap: widget.onRestart,
          glassColor: glassColor,
          borderColor: borderColor,
          textColor: textColor,
        ),
        _buildActionButton(
          icon: Icons.history_rounded,
          label: 'History',
          onTap: widget.onHistory,
          glassColor: glassColor,
          borderColor: borderColor,
          textColor: textColor,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color glassColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}