import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/ui/theme.dart' as theme;

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<int, Animation<double>> _tileAnimations = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateTile(int index) {
    if (!_tileAnimations.containsKey(index)) {
      _tileAnimations[index] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
      );
    }
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, gameProvider, settingsProvider, child) {
        final game = gameProvider.gameLogic;
        final themeType = settingsProvider.currentTheme.toAppThemeType();
        final winningPositions = game.winningLine?.positions ?? <int>[];

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: game.boardSize,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
            ),
            itemCount: game.boardSize * game.boardSize,
            itemBuilder: (context, index) {
              final row = index ~/ game.boardSize;
              final col = index % game.boardSize;
              final player = game.board![row][col];
              final isWinningTile = winningPositions.contains(index);
              final playerIcon = player != null
                  ? settingsProvider.getPlayerIcon(player)
                  : '';
              final playerName = player != null
                  ? settingsProvider.getPlayerName(player)
                  : '';

              return _AnimatedTile(
                key: ValueKey('$row-$col-${player?.toString()}'),
                onTap: () {
                  gameProvider.makeMove(row, col);
                  _animateTile(index);
                },
                isWinning: isWinningTile,
                playerIcon: playerIcon,
                playerName: playerName,
                themeType: themeType,
              );
            },
          ),
        );
      },
    );
  }
}

class _AnimatedTile extends StatefulWidget {
  final VoidCallback onTap;
  final bool isWinning;
  final String playerIcon;
  final String playerName;
  final AppThemeType themeType;

  const _AnimatedTile({
    required Key key,
    required this.onTap,
    required this.isWinning,
    required this.playerIcon,
    required this.playerName,
    required this.themeType,
  }) : super(key: key);

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_AnimatedTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWinning && !oldWidget.isWinning) {
      _controller.repeat(reverse: true);
    } else if (!widget.isWinning && oldWidget.isWinning) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glassColor = theme.AppTheme.getGlassColor(widget.themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(widget.themeType);
    final neonGlow = theme.AppTheme.getNeonGlowColor(widget.themeType);
    final winningColor = theme.AppTheme.getWinningLineColor(widget.themeType);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    glassColor,
                    glassColor.withOpacity(0.5),
                  ],
                ),
                border: Border.all(
                  color: widget.isWinning
                      ? winningColor.withOpacity(0.8 + _glowAnimation.value * 0.2)
                      : glassBorderColor,
                  width: widget.isWinning ? 3.0 : 1.5,
                ),
                boxShadow: [
                  if (widget.isWinning)
                    BoxShadow(
                      color: winningColor.withOpacity(0.6 + _glowAnimation.value * 0.4),
                      blurRadius: 20.0,
                      spreadRadius: 2.0,
                    )
                  else if (widget.playerIcon.isNotEmpty)
                    BoxShadow(
                      color: neonGlow.withOpacity(0.3),
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Center(
                    child: widget.playerIcon.isNotEmpty
                        ? Text(
                            widget.playerIcon,
                            style: TextStyle(
                              fontSize: widget.playerIcon.length == 1 ? 48.0 : 36.0,
                              fontWeight: FontWeight.bold,
                              color: widget.isWinning
                                  ? winningColor
                                  : Colors.white,
                              shadows: [
                                Shadow(
                                  color: widget.isWinning
                                      ? winningColor.withOpacity(0.8)
                                      : neonGlow.withOpacity(0.5),
                                  blurRadius: 10.0,
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
