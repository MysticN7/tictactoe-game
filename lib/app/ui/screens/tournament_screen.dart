import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/tournament_provider.dart';
import '../../logic/tournament_logic.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_provider.dart';
import '../../logic/game_logic.dart';
import '../widgets/game_board.dart';
import '../theme.dart' as theme;

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<SettingsProvider, GameProvider>(
          create: (_) => GameProvider(),
          update: (_, settings, game) => game!..setSettingsProvider(settings),
        ),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
      ],
      child: Consumer2<TournamentProvider, SettingsProvider>(
        builder: (context, tProvider, settings, _) {
          // Enforce 3-player mode
          if (settings.activePlayers.length != 3) {
            settings.setActivePlayers([Player.x, Player.o, Player.triangle]);
            context.read<GameProvider>().resetGame();
          }
          
          final t = tProvider.tournament;
          final themeType = settings.currentTheme.toAppThemeType();
          final gradientColors = theme.AppTheme.getGradientColors(themeType);
          
          return Scaffold(
            extendBodyBehindAppBar: true,
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
                    filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                    child: Container(color: Colors.black.withOpacity(0.25)),
                  ),
                  SafeArea(
                    child: t == null
                        ? _TournamentStartScreen(
                            onStart: () {
                              // Ensure 3 players are active
                              if (settings.activePlayers.length != 3) {
                                settings.setActivePlayers([Player.x, Player.o, Player.triangle]);
                              }
                              final players = settings.playerConfigs
                                  .where((c) => settings.activePlayers.contains(c.player))
                                  .map((c) => c.name)
                                  .take(3)
                                  .toList();
                              if (players.length == 3) {
                                tProvider.startTournament(players);
                                // Initialize game with 3 players
                                final gameProvider = context.read<GameProvider>();
                                gameProvider.resetGame();
                              }
                            },
                          )
                        : _TournamentGameScreen(),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (t != null && !t.isOver) {
                    // Show confirmation dialog if tournament is in progress
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Exit Tournament?'),
                        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Exit tournament
                            },
                            child: const Text('Exit'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Text(
                    'Tournament',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TournamentStartScreen extends StatelessWidget {
  final VoidCallback onStart;
  const _TournamentStartScreen({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.3),
                    Colors.orange.withOpacity(0.3),
                  ],
                ),
                border: Border.all(color: Colors.amber, width: 3),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Tournament Mode',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '3 Players • 3 Rounds\nWinner takes all!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 48),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                color: glassColor,
                border: Border.all(color: glassBorderColor, width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Column(
                    children: [
                      Text(
                        'Players',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...settings.playerConfigs
                          .where((c) => settings.activePlayers.contains(c.player))
                          .take(3)
                          .map((config) {
                        final color = settings.getPlayerColor(config.player);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: color, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    config.icon,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  config.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 8,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Start Tournament',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tProvider = context.watch<TournamentProvider>();
    final t = tProvider.tournament!;
    final gameProvider = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    
    // Ensure correct players are active for current round
    final currentPlayers = t.playersForCurrentGame;
    if (currentPlayers.isNotEmpty) {
      final currentPlayerEnums = currentPlayers.map((name) {
        return settings.playerConfigs.firstWhere(
          (c) => c.name == name,
          orElse: () => settings.playerConfigs.first,
        ).player;
      }).toList();
      
      if (settings.activePlayers.length != currentPlayerEnums.length ||
          !settings.activePlayers.every((p) => currentPlayerEnums.contains(p))) {
        settings.setActivePlayers(currentPlayerEnums);
        gameProvider.resetGame();
      }
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildRoundHeader(context, t, settings, glassColor, glassBorderColor),
          const SizedBox(height: 24),
          _buildProgressIndicator(context, t, settings),
          const SizedBox(height: 24),
          _buildCurrentPlayers(context, t, settings, glassColor, glassBorderColor),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              color: glassColor,
              border: Border.all(color: glassBorderColor, width: 2.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: const GameBoard(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (gameProvider.gameLogic.isGameOver && !t.isOver)
            _buildNextRoundButton(context, gameProvider, tProvider, settings),
          if (t.isOver) _buildTournamentWinner(context, t, tProvider, settings),
        ],
      ),
    );
  }

  Widget _buildRoundHeader(
    BuildContext context,
    TournamentLogic t,
    SettingsProvider settings,
    Color glassColor,
    Color glassBorderColor,
  ) {
    final roundNames = ['Round 1', 'Round 2', 'Final'];
    final roundName = t.currentRound <= 3 ? roundNames[t.currentRound - 1] : 'Complete';
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          colors: [
            glassColor,
            glassColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(color: glassBorderColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    roundName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
              if (t.currentRound == 1)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'All 3 players compete',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                )
              else if (t.currentRound == 2)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Remaining 2 players',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                )
              else if (t.currentRound == 3)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Championship Match',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    TournamentLogic t,
    SettingsProvider settings,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressStep(context, 1, t.currentRound > 1, t.currentRound > 1),
        _buildProgressLine(t.currentRound > 1),
        _buildProgressStep(context, 2, t.currentRound > 2, t.currentRound > 2),
        _buildProgressLine(t.currentRound > 2),
        _buildProgressStep(context, 3, t.isOver, t.currentRound >= 3),
      ],
    );
  }

  Widget _buildProgressStep(BuildContext context, int round, bool completed, bool active) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? Colors.green
            : active
                ? Colors.amber
                : Colors.grey.withOpacity(0.3),
        border: Border.all(
          color: active ? Colors.amber : Colors.grey,
          width: 3,
        ),
      ),
      child: Center(
        child: completed
            ? const Icon(Icons.check, color: Colors.white)
            : Text(
                '$round',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }

  Widget _buildProgressLine(bool completed) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: completed ? Colors.green : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildCurrentPlayers(
    BuildContext context,
    TournamentLogic t,
    SettingsProvider settings,
    Color glassColor,
    Color glassBorderColor,
  ) {
    final currentPlayers = t.playersForCurrentGame;
    if (currentPlayers.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: glassColor,
        border: Border.all(color: glassBorderColor, width: 2.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Column(
            children: [
              Text(
                'Current Match',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: currentPlayers.map((playerName) {
                  final config = settings.playerConfigs.firstWhere(
                    (c) => c.name == playerName,
                    orElse: () => settings.playerConfigs.first,
                  );
                  final color = settings.getPlayerColor(config.player);
                  return Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            config.icon,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        playerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextRoundButton(
    BuildContext context,
    GameProvider gameProvider,
    TournamentProvider tProvider,
    SettingsProvider settings,
  ) {
    final winner = gameProvider.gameLogic.winner;
    if (winner == null) return const SizedBox.shrink();
    
    final winnerName = settings.getPlayerName(winner);
    final winnerColor = settings.getPlayerColor(winner);
    final t = tProvider.tournament!;
    
    // Determine which players should be active for next round
    List<Player> nextRoundPlayers = [];
    if (t.currentRound == 1) {
      // Round 2: remaining 2 players (exclude round 1 winner)
      final round1WinnerPlayer = settings.playerConfigs
          .firstWhere((c) => c.name == t.round1Winner, orElse: () => settings.playerConfigs.first)
          .player;
      nextRoundPlayers = settings.activePlayers.where((p) => p != round1WinnerPlayer).toList();
    } else if (t.currentRound == 2) {
      // Round 3 (Final): round 1 winner vs round 2 winner
      final round1WinnerPlayer = settings.playerConfigs
          .firstWhere((c) => c.name == t.round1Winner, orElse: () => settings.playerConfigs.first)
          .player;
      final round2WinnerPlayer = settings.playerConfigs
          .firstWhere((c) => c.name == t.round2Winner, orElse: () => settings.playerConfigs.first)
          .player;
      nextRoundPlayers = [round1WinnerPlayer, round2WinnerPlayer];
    }
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          colors: [
            winnerColor.withOpacity(0.3),
            winnerColor.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: winnerColor, width: 2.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_rounded, color: winnerColor, size: 32),
              const SizedBox(width: 12),
              Text(
                '$winnerName Wins!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              tProvider.recordWin(winnerName);
              // Set up players for next round
              if (nextRoundPlayers.isNotEmpty) {
                settings.setActivePlayers(nextRoundPlayers);
              }
              gameProvider.resetGame();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: winnerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next Round',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentWinner(
    BuildContext context,
    TournamentLogic t,
    TournamentProvider tProvider,
    SettingsProvider settings,
  ) {
    final winnerConfig = settings.playerConfigs.firstWhere(
      (c) => c.name == t.tournamentWinner,
      orElse: () => settings.playerConfigs.first,
    );
    final winnerColor = settings.getPlayerColor(winnerConfig.player);
    
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        gradient: LinearGradient(
          colors: [
            winnerColor.withOpacity(0.4),
            winnerColor.withOpacity(0.2),
          ],
        ),
        border: Border.all(color: winnerColor, width: 3.0),
        boxShadow: [
          BoxShadow(
            color: winnerColor.withOpacity(0.5),
            blurRadius: 30.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: winnerColor.withOpacity(0.3),
              border: Border.all(color: winnerColor, width: 4),
            ),
            child: Text(
              winnerConfig.icon,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: winnerColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${t.tournamentWinner}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tournament Champion!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              tProvider.endTournament();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              backgroundColor: winnerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded),
                SizedBox(width: 8),
                Text(
                  'New Tournament',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
