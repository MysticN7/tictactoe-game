import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../logic/scores_provider.dart';
import '../../logic/game_logic.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_provider.dart';
import '../theme.dart' as theme;
import '../widgets/game_board.dart';
import '../widgets/particles_overlay.dart';
import 'settings_root_screen.dart';
import '../../utils/admob_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ParticlesController _confetti = ParticlesController();
  int _lastHistorySize = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.createBannerAd()
      ..load().then((_) {
        if (mounted) {
          setState(() {
            _isBannerAdReady = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _bannerAd?.dispose();
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
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(color: theme.AppTheme.getBackgroundOverlayColor(themeType)),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Scoreboard(
                              themeType: themeType,
                              settings: settings,
                              scores: scores,
                              activePlayers: settings.activePlayers,
                            ),
                            _SettingsButton(
                              themeType: themeType,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SettingsRootScreen()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (game.tournamentRound != TournamentRound.none)
                        _TournamentStatus(themeType: themeType, game: game, settings: settings),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Consumer<GameProvider>(
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
                                key: ValueKey(isOver ? 'over' : 'turn'),
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: theme.AppTheme.getGlassSurfaceColors(themeType)),
                                  border: Border.all(color: glassBorderColor, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 1),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isOver) ...[
                                      Text(context.read<SettingsProvider>().getPlayerIcon(player), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                                      const SizedBox(width: 8),
                                      Text("${name.toUpperCase()}'s Turn", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ] else ...[
                                      if (winner != null) ...[
                                        Text(context.read<SettingsProvider>().getPlayerIcon(winner), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.read<SettingsProvider>().getPlayerColor(winner))),
                                        const SizedBox(width: 8),
                                        Text("${context.read<SettingsProvider>().getPlayerName(winner).toUpperCase()} WINS", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ] else ...[
                                        const Icon(Icons.handshake_rounded, color: Colors.white),
                                        const SizedBox(width: 8),
                                        const Text("DRAW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ]
                                    ]
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                      if (game.tournamentRound != TournamentRound.none && game.gameLogic.isGameOver && game.tournamentRound != TournamentRound.champion)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: () => game.nextTournamentMatch(),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text("Next Match"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.AppTheme.getNeonGlowColor(themeType),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: _BottomActions(
                          themeType: themeType,
                          onUndo: () => game.undo(),
                          onRestart: () => game.resetGame(),
                          onHistory: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
                          onTournament: () {
                             if (game.tournamentRound != TournamentRound.none) {
                               game.stopTournament();
                             } else {
                               // Auto-switch to 3 players if needed
                               if (settings.activePlayers.length != 3) {
                                 settings.setActivePlayers(3);
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   const SnackBar(content: Text("Switched to 3-Player Mode for Tournament")),
                                 );
                               }
                               game.startTournament();
                             }
                          },
                          isTournamentActive: game.tournamentRound != TournamentRound.none,
                          canStartTournament: true,
                        ),
                      ),
                      if (_isBannerAdReady)
                        SizedBox(
                          height: _bannerAd!.size.height.toDouble(),
                          width: _bannerAd!.size.width.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      const SizedBox(height: 8),
                    ],
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

class _TournamentStatus extends StatelessWidget {
  final theme.AppThemeType themeType;
  final GameProvider game;
  final SettingsProvider settings;

  const _TournamentStatus({required this.themeType, required this.game, required this.settings});

  @override
  Widget build(BuildContext context) {
    String statusText = "";
    switch (game.tournamentRound) {
      case TournamentRound.round1:
        statusText = "Round 1: Qualifiers";
        break;
      case TournamentRound.round2:
        statusText = "Round 2: Semifinals";
        break;
      case TournamentRound.finalMatch:
        statusText = "Final Match";
        break;
      case TournamentRound.champion:
        statusText = "Champion: ${settings.getPlayerName(game.tournamentChampion!)}";
        break;
      default:
        statusText = "";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.AppTheme.getNeonGlowColor(themeType).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.AppTheme.getNeonGlowColor(themeType).withOpacity(0.5)),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: TextStyle(
          color: theme.AppTheme.getNeonGlowColor(themeType),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
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
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 25.0, spreadRadius: 0, offset: const Offset(0, 8)),
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
    return ScaleTransition(
      scale: _scale,
      child: RotationTransition(
        turns: _rotation,
        child: InkWell(
          onTap: _press,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10.0, spreadRadius: 1),
              ],
            ),
            child: const Icon(Icons.settings_rounded, size: 24, color: Colors.white),
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
    final gradientColors = theme.AppTheme.getGradientColors(themeType);
    final matches = context.watch<GameProvider>().matchHistory;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Match History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(color: theme.AppTheme.getBackgroundOverlayColor(themeType)),
             ),
             SafeArea(
               child: matches.isEmpty 
               ? const Center(child: Text("No matches yet", style: TextStyle(color: Colors.white70, fontSize: 18)))
               : ListView.separated(
                 padding: const EdgeInsets.all(16.0),
                 itemCount: matches.length,
                 separatorBuilder: (_, __) => const SizedBox(height: 10),
                 itemBuilder: (context, i) {
                   final m = matches[i];
                   final winnerName = m.winner != null ? settings.getPlayerName(m.winner!) : 'Draw';
                   final winnerColor = m.winner != null ? settings.getPlayerColor(m.winner!) : Colors.white70;
                   return Container(
                     padding: const EdgeInsets.all(16.0),
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(20.0),
                       color: glassColor,
                       border: Border.all(color: glassBorderColor, width: 1.5),
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
                         const SizedBox(width: 12),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(winnerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                               Text('${m.boardSize}x${m.boardSize} • Win ${m.winCondition}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                             ],
                           ),
                         ),
                         Text('${m.moveCount} moves', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                       ],
                     ),
                   );
                 },
               ),
             ),
          ],
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
    return Expanded(
      child: Row(
        children: players.map((p) {
          final color = settings.getPlayerColor(p);
          final winCount = scores.wins[p] ?? 0;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.AppTheme.getGlassSurfaceColors(themeType),
                ),
                border: Border.all(
                  color: glassBorderColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      settings.getPlayerName(p),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  Text(
                    '$winCount',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final theme.AppThemeType themeType;
  final VoidCallback onUndo;
  final VoidCallback onRestart;
  final VoidCallback onHistory;
  final VoidCallback onTournament;
  final bool isTournamentActive;
  final bool canStartTournament;

  const _BottomActions({
    required this.themeType,
    required this.onUndo,
    required this.onRestart,
    required this.onHistory,
    required this.onTournament,
    required this.isTournamentActive,
    required this.canStartTournament,
  });

  @override
  Widget build(BuildContext context) {
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final actionColors = theme.AppTheme.getGlassSurfaceColors(themeType);
    
    Widget buildButton(IconData icon, String label, VoidCallback onTap, {bool isActive = false, bool isDisabled = false}) {
      final opacity = isDisabled ? 0.5 : 1.0;
      return Expanded(
        child: Opacity(
          opacity: opacity,
          child: _ActionButton(
            gradientColors: isActive 
                ? [theme.AppTheme.getNeonGlowColor(themeType).withOpacity(0.4), theme.AppTheme.getNeonGlowColor(themeType).withOpacity(0.1)] 
                : actionColors,
            borderColor: isActive ? theme.AppTheme.getNeonGlowColor(themeType) : glassBorderColor,
            icon: icon,
            label: label,
            onTap: isDisabled ? () {} : onTap,
          ),
        ),
      );
    }
    return Row(
      children: [
        buildButton(Icons.undo_rounded, 'Undo', onUndo),
        const SizedBox(width: 12),
        buildButton(Icons.refresh_rounded, 'Restart', onRestart),
        const SizedBox(width: 12),
        buildButton(
          Icons.emoji_events_rounded, 
          isTournamentActive ? 'Stop' : 'Tourney', 
          onTournament, 
          isActive: isTournamentActive,
          isDisabled: !canStartTournament && !isTournamentActive
        ),
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
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: _press,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.gradientColors),
            border: Border.all(color: widget.borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8.0, spreadRadius: 0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(widget.label, style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}