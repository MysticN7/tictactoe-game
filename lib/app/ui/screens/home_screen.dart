import 'dart:async';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:tic_tac_toe_3_player/app/ui/widgets/particles_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/scores_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_logic.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/ui/widgets/game_board.dart';
import 'package:tic_tac_toe_3_player/app/utils/admob_service.dart';
import 'package:tic_tac_toe_3_player/app/ui/screens/settings_root_screen.dart';
import 'package:tic_tac_toe_3_player/app/ui/theme.dart' as theme;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  Timer? _bannerRefreshTimer;
  late AnimationController _turnAnimationController;
  late Animation<double> _turnScaleAnimation;
  late Animation<double> _turnSwayAnimation;
  late Animation<double> _turnGlowAnimation;
  late ConfettiController _confettiController;
  late ParticlesController _particlesController;
  bool _showHistory = false;
  Player? _lastWinner;

  @override
  void initState() {
    super.initState();
    _createBannerAd();
    _turnAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final curvedAnimation = CurvedAnimation(parent: _turnAnimationController, curve: Curves.easeOutBack);
    _turnScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(weight: 55, tween: Tween(begin: 0.94, end: 1.08)),
      TweenSequenceItem(weight: 45, tween: Tween(begin: 1.08, end: 1.0)),
    ]).animate(curvedAnimation);
    _turnSwayAnimation = TweenSequence<double>([
      TweenSequenceItem(weight: 30, tween: Tween(begin: 0.0, end: 6.0)),
      TweenSequenceItem(weight: 35, tween: Tween(begin: 6.0, end: -4.5)),
      TweenSequenceItem(weight: 35, tween: Tween(begin: -4.5, end: 0.0)),
    ]).animate(curvedAnimation);
    _turnGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(weight: 40, tween: Tween(begin: 0.35, end: 0.8)),
      TweenSequenceItem(weight: 60, tween: Tween(begin: 0.8, end: 0.45)),
    ]).animate(curvedAnimation);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _particlesController = ParticlesController();
  }

  void _createBannerAd() {
    _bannerRefreshTimer?.cancel();
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {});
            _startBannerRefreshTimer();
            if (kDebugMode) {
              print('AdMob: Banner ad loaded successfully');
            }
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('AdMob: Banner ad failed to load: ${error.code} - ${error.message}');
            print('AdMob: Domain: ${error.domain}, ResponseInfo: ${error.responseInfo}');
          }
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() {});
          }
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted && _bannerAd == null) {
              _createBannerAd();
            }
          });
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('AdMob: Banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('AdMob: Banner ad closed');
          }
          // Dispose and request a fresh banner when the user returns from the promo page
          _bannerRefreshTimer?.cancel();
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() {});
            // Immediately try to load a new banner so the slot is not left empty
            _createBannerAd();
          }
        },
      ),
    );
    _bannerAd?.load();
  }

  void _startBannerRefreshTimer() {
    _bannerRefreshTimer?.cancel();
    _bannerRefreshTimer = Timer(const Duration(minutes: 1), () {
      if (!mounted) return;
      if (kDebugMode) {
        print('AdMob: Refreshing banner manually to keep slot filled');
      }
      _bannerAd?.dispose();
      _bannerAd = null;
      setState(() {});
      _createBannerAd();
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerRefreshTimer?.cancel();
    _turnAnimationController.dispose();
    _confettiController.dispose();
    _particlesController.dispose();
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
          if (settingsProvider.isConfettiEnabled) {
            _particlesController.play();
          }
          try {
            Provider.of<ScoresProvider>(context, listen: false).increment(game.winner!);
          } catch (_) {}
        } else if (!game.isGameOver) {
          _lastWinner = null;
        }

        // Animate turn change (only if game is not over)
        if (game.currentPlayer != null && !game.isGameOver) {
          _turnAnimationController.forward(from: 0.0);
        } else if (game.isGameOver) {
          _turnAnimationController.stop();
        }

        return Scaffold(
          extendBodyBehindAppBar: false,
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
                    // Slightly lighter blur for better performance while keeping the liquid / glass look
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                      child: Container(color: Colors.black.withOpacity(0.22)),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: RepaintBoundary(
                              child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    _buildScoreboardBanner(context),
                                    const SizedBox(height: 10),
                                    _buildTurnIndicator(context, gameProvider, settingsProvider, neonGlow),
                                    const SizedBox(height: 16),
                                    _buildGameStatus(context, gameProvider, settingsProvider),
                                    const SizedBox(height: 16),
                                    const GameBoard(),
                                    const SizedBox(height: 16),
                                    if (_showHistory) _buildMatchHistory(context, gameProvider, settingsProvider),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Fixed action buttons at bottom
                          _buildActionButtons(context, gameProvider),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Liquidy settings button in top right
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: _buildLiquidSettingsButton(context, settingsProvider),
              ),
              // Confetti overlay
              Positioned.fill(child: ParticlesOverlay(controller: _particlesController, enabled: settingsProvider.isConfettiEnabled)),
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

  Widget _buildScoreboardBanner(BuildContext context) {
    return RepaintBoundary(
      child: Consumer2<ScoresProvider, SettingsProvider>(
        builder: (context, scores, settings, _) {
        final wins = scores.wins;
        final activePlayers = settings.activePlayers;
        final themeType = settings.currentTheme.toAppThemeType();
        final glassColor = theme.AppTheme.getGlassColor(themeType);
        final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
        final width = MediaQuery.of(context).size.width;
        final isMobile = width < 600;
        // Find current leader to highlight their card
        Player? leader;
        int topScore = -1;
        for (final p in activePlayers) {
          final score = wins[p] ?? 0;
          if (score > topScore) {
            topScore = score;
            leader = score > 0 ? p : null;
          }
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 16.0),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10.0 : 14.0, vertical: isMobile ? 8.0 : 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                glassColor.withOpacity(0.9),
                glassColor.withOpacity(0.6),
              ],
            ),
            border: Border.all(color: glassBorderColor.withOpacity(0.9), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 14.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: isMobile ? 6.0 : 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_rounded, color: Colors.amber.shade300, size: isMobile ? 18 : 20),
                        const SizedBox(width: 6),
                        Text(
                          'Battle Scoreboard',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: activePlayers.map((p) {
                      final color = settings.getPlayerColor(p);
                      final name = settings.getPlayerName(p);
                      final icon = settings.getPlayerIcon(p);
                      final count = wins[p] ?? 0;
                      final isLeader = leader == p;

                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutQuad,
                          margin: EdgeInsets.symmetric(horizontal: isMobile ? 3.0 : 4.0),
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 6.0 : 8.0, vertical: isMobile ? 7.0 : 9.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withOpacity(isLeader ? 0.35 : 0.22),
                                color.withOpacity(isLeader ? 0.18 : 0.10),
                              ],
                            ),
                            border: Border.all(
                              color: isLeader
                                  ? color.withOpacity(0.9)
                                  : color.withOpacity(0.45),
                              width: isLeader ? 1.6 : 1.1,
                            ),
                            boxShadow: isLeader
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.55),
                                      blurRadius: 14.0,
                                      spreadRadius: 0.8,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedScale(
                                    duration: const Duration(milliseconds: 250),
                                    scale: isLeader ? 1.1 : 1.0,
                                    curve: Curves.easeOutBack,
                                    child: Text(
                                      icon,
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                        shadows: [
                                          Shadow(
                                            color: color.withOpacity(0.85),
                                            blurRadius: 10.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isMobile ? 4 : 6),
                                  Flexible(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isMobile ? 9.5 : 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isMobile ? 4 : 5),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.25),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  key: ValueKey('count-$p-$count'),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 7 : 9,
                                    vertical: isMobile ? 3 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: color.withOpacity(0.8),
                                      width: 1.1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$count',
                                        style: TextStyle(
                                          color: color,
                                          fontSize: isMobile ? 12.5 : 14.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? 4 : 6),
                                      Text(
                                        'wins',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: isMobile ? 9 : 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      ),
    );
  }

  Widget _buildLiquidSettingsButton(BuildContext context, SettingsProvider settingsProvider) {
    final themeType = settingsProvider.currentTheme.toAppThemeType();
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final size = isMobile ? 48.0 : 52.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsRootScreen()),
          );
        },
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                glassColor,
                glassColor.withOpacity(0.8),
              ],
            ),
            border: Border.all(color: glassBorderColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              clipBehavior: Clip.antiAlias,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Icon(
                Icons.settings_rounded,
                color: Colors.white,
                size: isMobile ? 22 : 24,
              ),
            ),
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
    return RepaintBoundary(
      child: _buildTurnIndicatorContent(context, gameProvider, settingsProvider, neonGlow),
    );
  }

  Widget _buildTurnIndicatorContent(
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
        return Transform.translate(
          offset: Offset(_turnSwayAnimation.value, 0),
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
                    blurRadius: 12.0,
                    spreadRadius: 1.0,
                  ),
                ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: AnimatedBuilder(
                  animation: _turnAnimationController,
                  builder: (context, _) {
                    return Transform.scale(
                      scale: _turnScaleAnimation.value,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28.0),
                          boxShadow: [
                            BoxShadow(
                              color: playerColor.withOpacity(_turnGlowAnimation.value),
                              blurRadius: 18.0,
                              spreadRadius: 1.2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (playerIcon.isNotEmpty) ...[
                              AnimatedRotation(
                                turns: _turnAnimationController.value * 0.02,
                                duration: const Duration(milliseconds: 0),
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 300),
                                  scale: 1.0 + (_turnAnimationController.value * 0.1),
                                  child: Text(
                                    playerIcon,
                                    style: TextStyle(
                                      fontSize: 34.0,
                                      fontWeight: FontWeight.bold,
                                      color: playerColor,
                                      shadows: [
                                        Shadow(
                                          color: playerColor.withOpacity(0.85),
                                          blurRadius: 14.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                            ],
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  playerName,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'is making a move…',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white70,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
    return RepaintBoundary(
      child: _buildGameStatusContent(context, gameProvider, settingsProvider),
    );
  }

  Widget _buildGameStatusContent(
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
            blurRadius: 15.0,
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
    return RepaintBoundary(
      child: _buildActionButtonsContent(context, gameProvider),
    );
  }

  Widget _buildActionButtonsContent(BuildContext context, GameProvider gameProvider) {
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
                blurRadius: 8.0,
                spreadRadius: 0.5,
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
