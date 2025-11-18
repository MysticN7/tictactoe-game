import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_provider.dart';
import '../theme.dart' as theme;
import '../widgets/game_board.dart';
import 'settings_root_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, GameProvider>(
      builder: (context, settings, game, _) {
        final themeType = settings.currentTheme.toAppThemeType();
        final gradientColors = theme.AppTheme.getGradientColors(themeType);
        final glassColor = theme.AppTheme.getGlassColor(themeType);
        final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Tic Tac Toe 3 Player X O △'),
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
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(color: Colors.black.withAlpha((0.15 * 255).round())),
                ),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Liquid Glow',
                              style: Theme.of(context).textTheme.displayLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Play X O △ with glass morphism style',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            _GlassCard(
                              glassColor: glassColor,
                              glassBorderColor: glassBorderColor,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    _MenuButton(
                                      label: 'Play',
                                      icon: Icons.play_arrow_rounded,
                                      themeType: themeType,
                                      onTap: () {
                                        game.resetGame();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => _PlayScreen(themeType: themeType),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _MenuButton(
                                      label: 'Continue',
                                      icon: Icons.refresh_rounded,
                                      themeType: themeType,
                                      enabled: game.matchHistory.isNotEmpty && !game.gameLogic.isGameOver,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => _PlayScreen(themeType: themeType),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _MenuButton(
                                      label: 'Settings',
                                      icon: Icons.settings_rounded,
                                      themeType: themeType,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const SettingsRootScreen()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (game.matchHistory.isNotEmpty)
                              _GlassCard(
                                glassColor: glassColor,
                                glassBorderColor: glassBorderColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Recent Match', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(
                                        game.matchHistory.first.winner != null
                                            ? 'Winner: ${game.matchHistory.first.winner!.name.toUpperCase()}'
                                            : 'Draw',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glassColor, glassColor.withAlpha((0.7 * 255).round())],
        ),
        border: Border.all(color: glassBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha((0.1 * 255).round()), blurRadius: 20.0, spreadRadius: 0, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: child,
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final theme.AppThemeType themeType;
  final VoidCallback onTap;
  final bool enabled;
  const _MenuButton({required this.label, required this.icon, required this.themeType, required this.onTap, this.enabled = true});
  @override
  Widget build(BuildContext context) {
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final color = theme.AppTheme.getNeonGlowColor(themeType);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [glassColor, glassColor.withAlpha((0.6 * 255).round())],
            ),
            border: Border.all(color: enabled ? glassBorderColor : glassBorderColor.withAlpha((0.4 * 255).round()), width: 2.0),
            boxShadow: [
              BoxShadow(color: color.withAlpha((0.25 * 255).round()), blurRadius: 12.0, spreadRadius: 1.5),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(label, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayScreen extends StatelessWidget {
  final theme.AppThemeType themeType;
  const _PlayScreen({required this.themeType});
  @override
  Widget build(BuildContext context) {
    final glassColor = theme.AppTheme.getGlassColor(themeType);
    final glassBorderColor = theme.AppTheme.getGlassBorderColor(themeType);
    final gradientColors = theme.AppTheme.getGradientColors(themeType);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () => context.read<GameProvider>().resetGame(),
          ),
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            onPressed: () => context.read<GameProvider>().undoLastMove(),
          ),
        ],
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
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(color: Colors.black.withAlpha((0.12 * 255).round())),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _GlassCard(
                        glassColor: glassColor,
                        glassBorderColor: glassBorderColor,
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: GameBoard(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<GameProvider>(
                      builder: (context, game, _) {
                        final player = game.gameLogic.currentPlayer;
                        final name = context.read<SettingsProvider>().getPlayerName(player!);
                        final color = context.read<SettingsProvider>().getPlayerColor(player);
                        return Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: glassColor,
                            border: Border.all(color: glassBorderColor, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text('Turn: $name'),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}