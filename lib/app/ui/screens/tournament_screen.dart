import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/tournament_provider.dart';
import '../../logic/settings_provider.dart';
import '../../logic/game_provider.dart';
import '../widgets/game_board.dart';

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
      ],
      child: Consumer<TournamentProvider>(
        builder: (context, tProvider, _) {
          final t = tProvider.tournament;
          return Scaffold(
            appBar: AppBar(title: const Text('Tournament Mode')),
            body: Center(
              child: t == null
                  ? ElevatedButton(
                      onPressed: () {
                        final settings = context.read<SettingsProvider>();
                        final players = settings.playerConfigs.map((c) => c.name).toList();
                        tProvider.startTournament(players.take(3).toList());
                      },
                      child: const Text('Start Tournament'),
                    )
                  : _TournamentGame(),
            ),
          );
        },
      ),
    );
  }
}

class _TournamentGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tProvider = context.watch<TournamentProvider>();
    final t = tProvider.tournament!;
    final gameProvider = context.watch<GameProvider>();
    final settings = context.watch<SettingsProvider>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Round ${t.currentRound}', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const GameBoard(),
        const SizedBox(height: 12),
        if (gameProvider.gameLogic.isGameOver && !t.isOver)
          ElevatedButton(
            onPressed: () {
              final w = gameProvider.gameLogic.winner;
              if (w != null) {
                final wName = settings.getPlayerName(w);
                tProvider.recordWin(wName);
                gameProvider.resetGame();
              }
            },
            child: const Text('Next Round'),
          ),
        if (t.isOver)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('${t.tournamentWinner} wins the tournament!',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    tProvider.endTournament();
                  },
                  child: const Text('Restart Tournament'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}