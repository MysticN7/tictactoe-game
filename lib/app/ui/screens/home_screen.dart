import 'dart:ui';
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
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _turnAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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

        // Animate turn change
        if (game.currentPlayer != null) {
          _turnAnimationController.forward(from: 0.0);
        }

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
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(context, settingsProvider),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildTurnIndicator(context, gameProvider, settingsProvider, neonGlow),
                              const SizedBox(height: 20),
                              _buildGameStatus(context, gameProvider, settingsProvider),
                              const SizedBox(height: 20),
                              const GameBoard(),
                              const SizedBox(height: 20),
                              _buildActionButtons(context, gameProvider),
                              const SizedBox(height: 20),
                              if (_showHistory) _buildMatchHistory(context, gameProvider, settingsProvider),
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
    final glassColor = AppTheme.getGlassColor(themeType);
    final glassBorderColor = AppTheme.getGlassBorderColor(themeType);

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: glassColor,
        border: Border.all(color: glassBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AppBar(
            title: const Text('Tic Tac Toe 3 Player'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
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
    final playerName = currentPlayer != null
        ? settingsProvider.getPlayerName(currentPlayer)
        : 'Game Over';
    final playerIcon = currentPlayer != null
        ? settingsProvider.getPlayerIcon(currentPlayer)
        : '';

    return AnimatedBuilder(
      animation: _turnAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_turnAnimationController.value * 0.1),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            color: theme.AppTheme.getGlassColor(settingsProvider.currentTheme.toAppThemeType()),
            border: Border.all(
              color: neonGlow.withOpacity(0.6),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: neonGlow.withOpacity(0.4),
                  blurRadius: 20.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
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
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: neonGlow.withOpacity(0.8),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      game.isGameOver
                          ? (game.winner != null
                              ? '${settingsProvider.getPlayerName(game.winner!)} Wins!'
                              : 'Draw!')
                          : '$playerName\'s Turn',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 24.0,
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
            color: theme.AppTheme.getGlassColor(settingsProvider.currentTheme.toAppThemeType()),
            border: Border.all(
              color: theme.AppTheme.getWinningLineColor(settingsProvider.currentTheme.toAppThemeType()).withOpacity(0.6),
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Text(
            game.winner != null
                ? '🎉 ${settingsProvider.getPlayerName(game.winner!)} Wins! 🎉'
                : '🤝 It\'s a Draw!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 20.0,
                ),
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
                Icons.undo,
                gameProvider.gameLogic.moveHistory.isNotEmpty && !gameProvider.gameLogic.isGameOver,
                () => gameProvider.undoLastMove(),
                glassColor,
                glassBorderColor,
              ),
              _buildGlassButton(
                context,
                'Restart',
                Icons.refresh,
                true,
                () => gameProvider.resetGame(),
                glassColor,
                glassBorderColor,
              ),
              _buildGlassButton(
                context,
                _showHistory ? 'Hide History' : 'Show History',
                _showHistory ? Icons.arrow_drop_up : Icons.history,
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
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10.0,
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
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: enabled ? Colors.white : Colors.grey),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            color: enabled ? Colors.white : Colors.grey,
                            fontSize: 12.0,
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
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: theme.AppTheme.getGlassColor(settingsProvider.currentTheme.toAppThemeType()),
          border: Border.all(
            color: theme.AppTheme.getGlassBorderColor(settingsProvider.currentTheme.toAppThemeType()),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: const Text(
              'No match history yet',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16.0),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: AppTheme.getGlassColor(settingsProvider.currentTheme.toAppThemeType()),
        border: Border.all(
          color: AppTheme.getGlassBorderColor(settingsProvider.currentTheme.toAppThemeType()),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
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
                    return ListTile(
                      leading: Icon(
                        match.winner != null ? Icons.emoji_events : Icons.handshake,
                        color: match.winner != null
                            ? theme.AppTheme.getWinningLineColor(settingsProvider.currentTheme.toAppThemeType())
                            : Colors.grey,
                      ),
                      title: Text(
                        match.winner != null
                            ? '${settingsProvider.getPlayerName(match.winner!)} won'
                            : 'Draw',
                      ),
                      subtitle: Text(
                        '${match.boardSize}x${match.boardSize} board, ${match.winCondition} in a row\n${DateFormat('MMM d, HH:mm').format(match.timestamp)}',
                      ),
                      trailing: Text('${match.moveCount} moves'),
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
