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
  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, gameProvider, settingsProvider, child) {
        final game = gameProvider.gameLogic;
        final themeType = settingsProvider.currentTheme.toAppThemeType();
        
        // Collect all winning positions from all winning lines
        final Set<int> winningPositions = {};
        for (final line in game.allWinningLines) {
          winningPositions.addAll(line.positions);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final tileExtent = (size.shortestSide - 16.0 * 2 - 10.0 * (game.boardSize - 1)) / game.boardSize;
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
                      tileExtent: tileExtent,
                    );
                  },
                ),
              ),
            );
          },
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
  final double tileExtent;

  const _GameTile({
    required super.key,
    required this.row,
    required this.col,
    required this.player,
    required this.isWinning,
    required this.settingsProvider,
    required this.themeType,
    required this.onTap,
    required this.tileExtent,
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
      duration: const Duration(milliseconds: 800),
    );
    _controller.value = 1.0;
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
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
      _controller.value = 1.0;
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
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.AppTheme.getGlassSurfaceColors(widget.themeType),
              ),
              border: Border.all(
                color: widget.isWinning
                    ? winningColor.withOpacity(_glowAnimation.value)
                    : widget.player != null
                        ? playerColor.withOpacity(0.6)
                        : glassBorderColor.withOpacity(0.3),
                width: widget.isWinning ? 3.0 : 1.5,
              ),
              boxShadow: [
                if (widget.isWinning)
                  BoxShadow(
                    color: winningColor.withOpacity(_glowAnimation.value * 0.6),
                    blurRadius: 20.0,
                    spreadRadius: 2.0,
                  )
                else if (widget.player != null)
                  BoxShadow(
                    color: playerColor.withOpacity(0.3),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Center(
                child: playerIcon.isNotEmpty
                    ? ScaleTransition(
                        scale: _scaleAnimation,
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              playerColor,
                              playerColor.withOpacity(0.8),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: const [0.0, 0.7, 1.0],
                          ).createShader(bounds),
                          child: Text(
                            playerIcon,
                            style: TextStyle(
                              fontSize: _markerFontSize(widget.tileExtent, playerIcon),
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                BoxShadow(
                                  color: widget.isWinning
                                      ? winningColor.withOpacity(0.8)
                                      : playerColor.withOpacity(0.6),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  double _markerFontSize(double tileExtent, String icon) {
    final isSingleChar = icon.length == 1;
    return tileExtent * (isSingleChar ? 0.6 : 0.4);
  }
}
