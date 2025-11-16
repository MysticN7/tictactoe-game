import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/scores_provider.dart';
import 'package:tic_tac_toe_3_player/app/ui/screens/home_screen.dart';
import 'package:tic_tac_toe_3_player/app/ui/theme.dart' as theme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob
  final initFuture = MobileAds.instance.initialize();
  if (kDebugMode) {
    print('AdMob: Initializing...');
    initFuture.then((value) {
      print('AdMob: Initialization complete');
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadPersistence()),
        ChangeNotifierProvider(create: (_) => ScoresProvider()..load()),
        ChangeNotifierProxyProvider<SettingsProvider, GameProvider>(
          create: (_) => GameProvider(),
          update: (_, settings, game) => game!..setSettingsProvider(settings),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'Tic Tac Toe 3 Player X O △',
          theme: theme.AppTheme.getTheme(settingsProvider.currentTheme.toAppThemeType()),
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
