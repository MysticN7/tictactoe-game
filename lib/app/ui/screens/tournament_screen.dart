import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/game_provider.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_logic.dart';
import '../theme.dart';
import '../widgets/game_board.dart';
import '../widgets/liquid_components.dart';
import '../widgets/particles_overlay.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final ParticlesController _confetti = ParticlesController();

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, game, settings, _) {
        final themeType = settings.currentTheme.toAppThemeType();
        final gradientColors = AppTheme.getGradientColors(themeType);
        final textColor = AppTheme.getTextColor(themeType);
        final tournament = game.tournament;

        // Confetti for Champion
        if (tournament.champion != null && settings.isConfettiEnabled) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: LiquidAppBar(
            title: 'Tournament',
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
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
                // Background Overlay
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                  child: Container(color: AppTheme.getBackgroundOverlayColor(themeType)),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _TournamentHeader(tournament: tournament, themeType: themeType),
                        const SizedBox(height: 20),
                        
                        if (tournament.champion != null)
                          Expanded(child: _ChampionView(champion: tournament.champion!, themeType: themeType, settings: settings))
                        else if (tournament.currentRound == 3 && game.gameLogic.isGameOver)
                          Expanded(child: _IntermissionView(tournament: tournament, themeType: themeType, onStart: () => game.startNextRound()))
                        else
                          Expanded(
                            child: Column(
                              children: [
                                _TournamentScoreboard(tournament: tournament, settings: settings, themeType: themeType),
                                const SizedBox(height: 20),
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
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Confetti Overlay
                if (settings.isConfettiEnabled)
                  ParticlesOverlay(controller: _confetti, enabled: true),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TournamentHeader extends StatelessWidget {
  final TournamentState tournament;
  final AppThemeType themeType;

  const _TournamentHeader({required this.tournament, required this.themeType});

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.getTextColor(themeType);
    String statusText = "";
    String subText = "";

    if (tournament.champion != null) {
      statusText = "TOURNAMENT OVER";
      subText = "We have a Champion!";
    } else if (tournament.currentRound == 1) {
      statusText = "SURVIVAL ROUND";
      subText = "3 Players • 1st Winner Advances";
    } else if (tournament.currentRound == 2) {
      statusText = "SURVIVAL ROUND";
      subText = "2 Players Left • 2nd Winner Advances";
    } else if (tournament.currentRound == 3) {
      statusText = "FINAL MATCH";
      subText = "1v1 for the Championship";
    }

    return Column(
      children: [
        Text(
          statusText,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subText,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TournamentScoreboard extends StatelessWidget {
  final TournamentState tournament;
  final SettingsProvider settings;
  final AppThemeType themeType;

  const _TournamentScoreboard({
    required this.tournament,
    required this.settings,
    required this.themeType,
  });

  @override
  Widget build(BuildContext context) {
    // Show all 3 players, but mark eliminated ones
    final allPlayers = [Player.x, Player.o, Player.triangle];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: allPlayers.map((p) {
        final isEliminated = tournament.eliminatedPlayers.contains(p);
        final isWinner = (tournament.round1Winner == p || tournament.round2Winner == p || tournament.champion == p);
        final isActive = tournament.activePlayers.contains(p);
        
        return _PlayerCard(
          player: p,
          settings: settings,
          themeType: themeType,
          isEliminated: isEliminated,
          isWinner: isWinner,
          isActive: isActive,
        );
      }).toList(),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player player;
  final SettingsProvider settings;
  final AppThemeType themeType;
  final bool isEliminated;
  final bool isWinner;
  final bool isActive;

  const _PlayerCard({
    required this.player,
    required this.settings,
    required this.themeType,
    required this.isEliminated,
    required this.isWinner,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = settings.getPlayerColor(player);
    final textColor = AppTheme.getTextColor(themeType);
    final glassColor = AppTheme.getGlassColor(themeType);
    final borderColor = AppTheme.getGlassBorderColor(themeType);

    return Opacity(
      opacity: isEliminated ? 0.4 : 1.0,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: glassColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWinner ? AppTheme.getWinningLineColor(themeType) : (isActive ? color : borderColor),
            width: isWinner || isActive ? 2 : 1,
          ),
          boxShadow: [
            if (isWinner)
              BoxShadow(color: AppTheme.getWinningLineColor(themeType).withOpacity(0.4), blurRadius: 10)
            else if (isActive)
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(
              isWinner ? Icons.emoji_events : (isEliminated ? Icons.close : Icons.person),
              color: isWinner ? AppTheme.getWinningLineColor(themeType) : color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              settings.getPlayerName(player),
              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            if (isWinner)
              Text("Qualified", style: TextStyle(color: AppTheme.getWinningLineColor(themeType), fontSize: 10, fontWeight: FontWeight.w900))
            else if (isEliminated)
              Text("Eliminated", style: TextStyle(color: Colors.red.withOpacity(0.8), fontSize: 10))
          ],
        ),
      ),
    );
  }
}

class _IntermissionView extends StatelessWidget {
  final TournamentState tournament;
  final AppThemeType themeType;
  final VoidCallback onStart;

  const _IntermissionView({required this.tournament, required this.themeType, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.getTextColor(themeType);
    final glowColor = AppTheme.getNeonGlowColor(themeType);

    return Center(
      child: LiquidContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_mma_rounded, size: 60, color: glowColor),
            const SizedBox(height: 20),
            Text(
              "FINAL MATCH READY",
              style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "The survivors are ready to clash!",
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: glowColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 8,
                shadowColor: glowColor.withOpacity(0.5),
              ),
              child: const Text("START FINAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChampionView extends StatelessWidget {
  final Player champion;
  final AppThemeType themeType;
  final SettingsProvider settings;

  const _ChampionView({required this.champion, required this.themeType, required this.settings});

  @override
  Widget build(BuildContext context) {
    final textColor = AppTheme.getTextColor(themeType);
    final championColor = settings.getPlayerColor(champion);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: championColor.withOpacity(0.2),
              boxShadow: [
                BoxShadow(color: championColor.withOpacity(0.6), blurRadius: 50, spreadRadius: 10),
              ],
              border: Border.all(color: championColor, width: 4),
            ),
            child: Icon(Icons.emoji_events_rounded, size: 100, color: championColor),
          ),
          const SizedBox(height: 30),
          Text(
            "CHAMPION",
            style: TextStyle(color: textColor, fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 10),
          Text(
            settings.getPlayerName(champion),
            style: TextStyle(color: championColor, fontSize: 40, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.home_rounded),
            label: const Text("BACK TO MENU"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getGlassColor(themeType),
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppTheme.getGlassBorderColor(themeType))),
            ),
          ),
        ],
      ),
    );
  }
}
