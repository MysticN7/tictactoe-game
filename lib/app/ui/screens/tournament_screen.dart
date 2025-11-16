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
            extendBodyBehindAppBar: false,
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
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                      child: Container(color: Colors.black.withOpacity(0.25)),
                    ),
                  ),
                  SafeArea(
                    child: t == null
                        ? _TournamentStartView(
                            onStart: () {
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
                                context.read<GameProvider>().resetGame();
                              }
                            },
                          )
                        : _TournamentGameView(),
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

class _TournamentStartView extends StatelessWidget {
  final VoidCallback onStart;
  const _TournamentStartView({required this.onStart});

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
                      }),
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

class _TournamentGameView extends StatefulWidget {
  const _TournamentGameView();

  @override
  State<_TournamentGameView> createState() => _TournamentGameViewState();
}

class _TournamentGameViewState extends State<_TournamentGameView> {
  int? _lastRound;
  bool _playersInitialized = false;

  void _ensurePlayersForRound(TournamentLogic t, SettingsProvider settings, GameProvider gameProvider) {
    if (!mounted) return;
    
    final currentPlayers = t.playersForCurrentGame;
    if (currentPlayers.isEmpty) return;
    
    final currentPlayerEnums = currentPlayers.map((name) {
      return settings.playerConfigs.firstWhere(
        (c) => c.name == name,
        orElse: () => settings.playerConfigs.first,
      ).player;
    }).toList();
    
    final needsUpdate = settings.activePlayers.length != currentPlayerEnums.length ||
        !settings.activePlayers.every((p) => currentPlayerEnums.contains(p));
    
    if (needsUpdate) {
      settings.setActivePlayers(currentPlayerEnums);
      gameProvider.resetGame();
      _playersInitialized = true;
    } else if (!_playersInitialized) {
      gameProvider.resetGame();
      _playersInitialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tProvider = context.watch<TournamentProvider>();
    final t = tProvider.tournament;
    final gameProvider = context.read<GameProvider>();
    final settings = context.read<SettingsProvider>();
    
    if (t != null) {
      if (_lastRound != t.currentRound) {
        _lastRound = t.currentRound;
        _playersInitialized = false;
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && t == tProvider.tournament) {
          _ensurePlayersForRound(t, settings, gameProvider);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tProvider = context.watch<TournamentProvider>();
    final t = tProvider.tournament!;
    final gameProvider = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();
    final themeType = settings.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return ClipRect(
      child: SingleChildScrollView(
        clipBehavior: Clip.antiAlias,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          children: [
            SizedBox(height: isMobile ? 8 : 16),
            // Back button and title
            _buildHeader(context, t, settings, glassColor, glassBorderColor, isMobile),
            SizedBox(height: isMobile ? 16 : 24),
            // Round header
            _buildRoundHeader(context, t, settings, glassColor, glassBorderColor, isMobile),
            SizedBox(height: isMobile ? 16 : 24),
            // Progress indicator
            _buildProgressIndicator(context, t, settings, isMobile),
            SizedBox(height: isMobile ? 16 : 24),
            // Current players
            _buildCurrentPlayers(context, t, settings, glassColor, glassBorderColor, isMobile),
            SizedBox(height: isMobile ? 16 : 24),
            // Game board
            Container(
              clipBehavior: Clip.antiAlias,
              padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.0),
                color: glassColor,
                border: Border.all(color: glassBorderColor, width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                clipBehavior: Clip.antiAlias,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: const GameBoard(),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            // Next round button or winner
            if (gameProvider.gameLogic.isGameOver && !t.isOver)
              _buildNextRoundButton(context, gameProvider, tProvider, settings, isMobile),
            if (t.isOver)
              _buildTournamentWinner(context, t, tProvider, settings, isMobile),
            SizedBox(height: isMobile ? 16 : 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    TournamentLogic t,
    SettingsProvider settings,
    Color glassColor,
    Color glassBorderColor,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 16.0, vertical: isMobile ? 10.0 : 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: glassColor,
        border: Border.all(color: glassBorderColor, width: 2.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () {
                  if (!t.isOver) {
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
                              Navigator.pop(context);
                              Navigator.pop(context);
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
              const SizedBox(width: 8),
              Icon(Icons.emoji_events_rounded, color: Colors.amber, size: isMobile ? 20 : 24),
              const SizedBox(width: 8),
              Text(
                'Tournament',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundHeader(
    BuildContext context,
    TournamentLogic t,
    SettingsProvider settings,
    Color glassColor,
    Color glassBorderColor,
    bool isMobile,
  ) {
    final roundNames = ['Round 1', 'Round 2', 'Final'];
    final roundName = t.currentRound <= 3 ? roundNames[t.currentRound - 1] : 'Complete';
    final roundDescriptions = [
      'All 3 players compete',
      'Remaining 2 players',
      'Championship Match',
    ];
    final roundDescription = t.currentRound <= 3 ? roundDescriptions[t.currentRound - 1] : '';
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
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
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_rounded, color: Colors.amber, size: isMobile ? 28 : 32),
                  SizedBox(width: isMobile ? 8 : 12),
                  Flexible(
                    child: Text(
                      roundName,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              if (roundDescription.isNotEmpty) ...[
                SizedBox(height: isMobile ? 8 : 12),
                Text(
                  roundDescription,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
    bool isMobile,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressStep(context, 1, t.currentRound > 1, t.currentRound > 1, isMobile),
        _buildProgressLine(t.currentRound > 1, isMobile),
        _buildProgressStep(context, 2, t.currentRound > 2, t.currentRound > 2, isMobile),
        _buildProgressLine(t.currentRound > 2, isMobile),
        _buildProgressStep(context, 3, t.isOver, t.currentRound >= 3, isMobile),
      ],
    );
  }

  Widget _buildProgressStep(BuildContext context, int round, bool completed, bool active, bool isMobile) {
    final size = isMobile ? 40.0 : 50.0;
    final fontSize = isMobile ? 16.0 : 18.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed
            ? Colors.green
            : active
                ? Colors.amber
                : Colors.grey.withOpacity(0.3),
        border: Border.all(
          color: active ? Colors.amber : Colors.grey,
          width: isMobile ? 2.5 : 3,
        ),
      ),
      child: Center(
        child: completed
            ? Icon(Icons.check, color: Colors.white, size: isMobile ? 20 : 24)
            : Text(
                '$round',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
      ),
    );
  }

  Widget _buildProgressLine(bool completed, bool isMobile) {
    return Expanded(
      child: Container(
        height: isMobile ? 2.5 : 3,
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8),
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
    bool isMobile,
  ) {
    final currentPlayers = t.playersForCurrentGame;
    if (currentPlayers.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: glassColor,
        border: Border.all(color: glassBorderColor, width: 2.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Column(
            children: [
              Text(
                'Current Match',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: currentPlayers.map((playerName) {
                  final config = settings.playerConfigs.firstWhere(
                    (c) => c.name == playerName,
                    orElse: () => settings.playerConfigs.first,
                  );
                  final color = settings.getPlayerColor(config.player);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isMobile ? 50 : 60,
                        height: isMobile ? 50 : 60,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: isMobile ? 2.5 : 3),
                        ),
                        child: Center(
                          child: Text(
                            config.icon,
                            style: TextStyle(
                              fontSize: isMobile ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      SizedBox(
                        width: isMobile ? 60 : 80,
                        child: Text(
                          playerName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 11 : 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    bool isMobile,
  ) {
    final winner = gameProvider.gameLogic.winner;
    if (winner == null) return const SizedBox.shrink();
    
    final winnerName = settings.getPlayerName(winner);
    final winnerColor = settings.getPlayerColor(winner);
    final t = tProvider.tournament!;
    
    // Determine players for next round
    final currentRound = t.currentRound;
    List<Player> nextRoundPlayers = [];
    if (currentRound == 1) {
      nextRoundPlayers = settings.activePlayers.where((p) => p != winner).toList();
    } else if (currentRound == 2) {
      final round1WinnerPlayer = settings.playerConfigs
          .firstWhere((c) => c.name == t.round1Winner, orElse: () => settings.playerConfigs.first)
          .player;
      nextRoundPlayers = [round1WinnerPlayer, winner];
    }
    
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
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
              Icon(Icons.emoji_events_rounded, color: winnerColor, size: isMobile ? 28 : 32),
              SizedBox(width: isMobile ? 8 : 12),
              Flexible(
                child: Text(
                  '$winnerName Wins!',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ElevatedButton(
            onPressed: () {
              tProvider.recordWin(winnerName);
              if (nextRoundPlayers.isNotEmpty) {
                settings.setActivePlayers(nextRoundPlayers);
              }
              gameProvider.resetGame();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 32, vertical: isMobile ? 12 : 16),
              backgroundColor: winnerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Next Round',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8),
                const Icon(Icons.arrow_forward_rounded),
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
    bool isMobile,
  ) {
    final winnerConfig = settings.playerConfigs.firstWhere(
      (c) => c.name == t.tournamentWinner,
      orElse: () => settings.playerConfigs.first,
    );
    final winnerColor = settings.getPlayerColor(winnerConfig.player);
    
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
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
            padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: winnerColor.withOpacity(0.3),
              border: Border.all(color: winnerColor, width: 4),
            ),
            child: Text(
              winnerConfig.icon,
              style: TextStyle(
                fontSize: isMobile ? 48 : 64,
                fontWeight: FontWeight.bold,
                color: winnerColor,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            t.tournamentWinner ?? '',
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'Tournament Champion!',
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 24 : 32),
          ElevatedButton(
            onPressed: () {
              tProvider.endTournament();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 40, vertical: isMobile ? 14 : 18),
              backgroundColor: winnerColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'New Tournament',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
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
