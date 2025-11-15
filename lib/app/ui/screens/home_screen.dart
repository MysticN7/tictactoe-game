import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_logic.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/ui/widgets/game_board.dart';
import 'package:tic_tac_toe_3_player/app/utils/admob_service.dart';
import 'package:tic_tac_toe_3_player/app/ui/screens/settings_screen.dart';
import 'package:tic_tac_toe_3_player/app/ui/theme.dart' as theme;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  late AnimationController _turnAnimationController;
  late ConfettiController _confettiController;
  bool _showHistory = false;
  Player? _lastWinner;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _turnAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _turnAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, gameProvider, settingsProvider, child) {
        final game = gameProvider.gameLogic;
        final themeType = settingsProvider.currentTheme.toAppThemeType();
        final gradientColors = theme.AppTheme.getGradientColors(themeType);
        final neonGlow = theme.AppTheme.getNeonGlowColor(themeType);

        // Handle confetti on win
        if (game.isGameOver && game.winner != null && game.winner != _lastWinner) {
          _lastWinner = game.winner;
          _confettiController.play();
        } else if (!game.isGameOver) {
          _lastWinner = null;
        }

        // Animate turn change
        if (game.currentPlayer != null) {
          _turnAnimationController.forward(from: 0.0);
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              Container(
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
                      child: Container(color: Colors.black.withOpacity(0.25)),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          _buildAppBar(context, settingsProvider),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  _buildTurnIndicator(context, gameProvider, settingsProvider, neonGlow),
                                  const SizedBox(height: 16),
                                  _buildGameStatus(context, gameProvider, settingsProvider),
                                  const SizedBox(height: 16),
                                  const GameBoard(),
                                  const SizedBox(height: 16),
                                  _buildActionButtons(context, gameProvider),
                                  const SizedBox(height: 16),
                                  if (_showHistory) _buildMatchHistory(context, gameProvider, settingsProvider),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 1.57, // Down
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [
                    Colors.red,
                    Colors.blue,
                    Colors.yellow,
                    Colors.green,
                    Colors.purple,
                    Colors.orange,
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _bannerAd == null
              ? null
              : SizedBox(
                  height: 50,
                  child: AdWidget(ad: _bannerAd!),
                ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, SettingsProvider settingsProvider) {
    final themeType = settingsProvider.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: glassColor,
        border: Border.all(color: glassBorderColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: AppBar(
            title: const Text(
              'Tic Tac Toe',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurnIndicator(
    BuildContext context,
    GameProvider gameProvider,
    SettingsProvider settingsProvider,
    Color neonGlow,
  ) {
    final game = gameProvider.gameLogic;
    final currentPlayer = game.currentPlayer;
    
    if (game.isGameOver) {
      return const SizedBox.shrink();
    }

    final playerName = currentPlayer != null
        ? settingsProvider.getPlayerName(currentPlayer)
        : '';
    final playerIcon = currentPlayer != null
        ? settingsProvider.getPlayerIcon(currentPlayer)
        : '';
    final playerColor = currentPlayer != null
        ? settingsProvider.getPlayerColor(currentPlayer)
        : Colors.white;

    return AnimatedBuilder(
      animation: _turnAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_turnAnimationController.value * 0.08),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  playerColor.withOpacity(0.2),
                  playerColor.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: playerColor.withOpacity(0.6),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: playerColor.withOpacity(0.4),
                  blurRadius: 25.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (playerIcon.isNotEmpty) ...[
                      Text(
                        playerIcon,
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: playerColor,
                          shadows: [
                            Shadow(
                              color: playerColor.withOpacity(0.8),
                              blurRadius: 12.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Text(
                      '$playerName\'s Turn',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameStatus(
    BuildContext context,
    GameProvider gameProvider,
    SettingsProvider settingsProvider,
  ) {
    final game = gameProvider.gameLogic;
    if (!game.isGameOver) return const SizedBox.shrink();

    final winnerColor = game.winner != null
        ? settingsProvider.getPlayerColor(game.winner!)
        : Colors.grey;
    final winnerName = game.winner != null
        ? settingsProvider.getPlayerName(game.winner!)
        : '';
    final winnerIcon = game.winner != null
        ? settingsProvider.getPlayerIcon(game.winner!)
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            winnerColor.withOpacity(0.25),
            winnerColor.withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: winnerColor.withOpacity(0.7),
          width: 3.0,
        ),
        boxShadow: [
          BoxShadow(
            color: winnerColor.withOpacity(0.5),
            blurRadius: 30.0,
            spreadRadius: 3.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (game.winner != null) ...[
                Text(
                  winnerIcon,
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: winnerColor,
                    shadows: [
                      Shadow(
                        color: winnerColor.withOpacity(0.9),
                        blurRadius: 15.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$winnerName Wins!',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ] else
                Text(
                  '🤝 It\'s a Draw!',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameProvider gameProvider) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final themeType = settingsProvider.currentTheme.toAppThemeType();
        final glassColor = theme.AppTheme.getGlassColor(themeType);
        final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGlassButton(
                context,
                'Undo',
                Icons.undo_rounded,
                gameProvider.gameLogic.moveHistory.isNotEmpty && !gameProvider.gameLogic.isGameOver,
                () => gameProvider.undoLastMove(),
                glassColor,
                glassBorderColor,
              ),
              _buildGlassButton(
                context,
                'Restart',
                Icons.refresh_rounded,
                true,
                () => gameProvider.resetGame(),
                glassColor,
                glassBorderColor,
              ),
              _buildGlassButton(
                context,
                _showHistory ? 'Hide' : 'History',
                _showHistory ? Icons.arrow_drop_up_rounded : Icons.history_rounded,
                true,
                () => setState(() => _showHistory = !_showHistory),
                glassColor,
                glassBorderColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassButton(
    BuildContext context,
    String label,
    IconData icon,
    bool enabled,
    VoidCallback onPressed,
    Color glassColor,
    Color glassBorderColor,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: glassColor,
            border: Border.all(color: glassBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: enabled ? onPressed : null,
                  borderRadius: BorderRadius.circular(20.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: enabled ? Colors.white : Colors.grey.shade600, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: enabled ? Colors.white : Colors.grey.shade600,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHistory(
    BuildContext context,
    GameProvider gameProvider,
    SettingsProvider settingsProvider,
  ) {
    final history = gameProvider.matchHistory;
    if (history.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: theme.AppTheme.getGlassColor(settingsProvider.currentTheme.toAppThemeType()),
          border: Border.all(
            color: theme.AppTheme.getGlassBorderColor(settingsProvider.currentTheme.toAppThemeType()),
            width: 2.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: const Text(
              'No match history yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16.0),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: theme.AppTheme.getGlassColor(settingsProvider.currentTheme.toAppThemeType()),
        border: Border.all(
          color: theme.AppTheme.getGlassBorderColor(settingsProvider.currentTheme.toAppThemeType()),
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Match History',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => gameProvider.clearMatchHistory(),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final match = history[index];
                    final winnerColor = match.winner != null
                        ? settingsProvider.getPlayerColor(match.winner!)
                        : Colors.grey;
                    return ListTile(
                      leading: Icon(
                        match.winner != null ? Icons.emoji_events_rounded : Icons.handshake_rounded,
                        color: winnerColor,
                      ),
                      title: Text(
                        match.winner != null
                            ? '${settingsProvider.getPlayerName(match.winner!)} won'
                            : 'Draw',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${match.boardSize}x${match.boardSize} • ${match.winCondition} in a row\n${DateFormat('MMM d, HH:mm').format(match.timestamp)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        '${match.moveCount} moves',
                        style: const TextStyle(color: Colors.white60),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
