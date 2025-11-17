import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_logic.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/ui/theme.dart' as theme;

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, gameProvider, settingsProvider, child) {
        final game = gameProvider.gameLogic;
        final themeType = settingsProvider.currentTheme.toAppThemeType();
        final winningPositions = game.winningLine?.positions ?? <int>[];

        return RepaintBoundary(
          child: Container(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: game.boardSize,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: game.boardSize * game.boardSize,
            itemBuilder: (context, index) {
              final row = index ~/ game.boardSize;
              final col = index % game.boardSize;
              final player = game.board![row][col];
              final isWinningTile = winningPositions.contains(index);

              return _GameTile(
                key: ValueKey('tile-$row-$col'),
                row: row,
                col: col,
                player: player,
                isWinning: isWinningTile,
                settingsProvider: settingsProvider,
                themeType: themeType,
                onTap: () => gameProvider.makeMove(row, col),
              );
            },
          ),
        ),
        );
      },
    );
  }
}

class _GameTile extends StatefulWidget {
  final int row;
  final int col;
  final Player? player;
  final bool isWinning;
  final SettingsProvider settingsProvider;
  final theme.AppThemeType themeType;
  final VoidCallback onTap;

  const _GameTile({
    required super.key,
    required this.row,
    required this.col,
    required this.player,
    required this.isWinning,
    required this.settingsProvider,
    required this.themeType,
    required this.onTap,
  });

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isWinning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWinning && !oldWidget.isWinning) {
      _controller.repeat(reverse: true);
    } else if (!widget.isWinning && oldWidget.isWinning) {
      _controller.stop();
      _controller.reset();
    }
    if (widget.player != null && oldWidget.player == null) {
      _controller.forward(from: 0.0);
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
    final playerColor = widget.player != null
        ? widget.settingsProvider.getPlayerColor(widget.player!)
        : Colors.transparent;
    final playerIcon = widget.player != null
        ? widget.settingsProvider.getPlayerIcon(widget.player!)
        : '';
    final winningColor = theme.AppTheme.getWinningLineColor(widget.themeType);

    return GestureDetector(
      onTap: () => widget.onTap(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    glassColor,
                    glassColor.withOpacity(0.6),
                  ],
                ),
                border: Border.all(
                  color: widget.isWinning
                      ? winningColor.withOpacity(0.7 + _glowAnimation.value * 0.2)
                      : widget.player != null
                          ? playerColor.withOpacity(0.4)
                          : glassBorderColor,
                  width: widget.isWinning ? 2.5 : 2.0,
                ),
                boxShadow: [
                  if (widget.isWinning)
                    BoxShadow(
                      color: winningColor.withOpacity(0.5 + _glowAnimation.value * 0.2),
                      blurRadius: 12.0,
                      spreadRadius: 1.0,
                    )
                  else if (widget.player != null)
                    BoxShadow(
                      color: playerColor.withOpacity(0.3),
                      blurRadius: 8.0,
                      spreadRadius: 0.5,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                // Removed per-tile BackdropFilter to avoid heavy compositing on every tap,
                // which can cause white flashes on some devices. The overall glass look
                // still comes from the screen background and card styling.
                child: Center(
                  child: playerIcon.isNotEmpty
                      ? Text(
                          playerIcon,
                          style: TextStyle(
                            fontSize: _markerFontSize(widget.settingsProvider.boardSize, playerIcon),
                            fontWeight: FontWeight.bold,
                            color: widget.isWinning
                                ? winningColor
                                : playerColor,
                            shadows: [
                              Shadow(
                                color: widget.isWinning
                                    ? winningColor.withOpacity(0.9)
                                    : playerColor.withOpacity(0.6),
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _markerFontSize(int boardSize, String icon) {
    final isSingleChar = icon.length == 1;
    switch (boardSize) {
      case 3:
        return isSingleChar ? 64.0 : 52.0;
      case 4:
        return isSingleChar ? 52.0 : 44.0;
      case 5:
      default:
        return isSingleChar ? 44.0 : 36.0;
    }
  }
}
