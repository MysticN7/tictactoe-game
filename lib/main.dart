import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/game_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/settings_provider.dart';
import 'package:tic_tac_toe_3_player/app/logic/scores_provider.dart';
import 'package:tic_tac_toe_3_player/app/ui/screens/home_screen.dart';
import 'package:tic_tac_toe_3_player/app/ui/theme.dart' as theme;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize AdMob before running the app to avoid any race conditions
  if (kDebugMode) {
    print('AdMob: Initializing...');
  }
  final initStatus = await MobileAds.instance.initialize();
  if (kDebugMode) {
    print('AdMob: Initialization complete: $initStatus');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadPersistence()),
        ChangeNotifierProvider(create: (_) => ScoresProvider()..load()),
        ChangeNotifierProxyProvider2<SettingsProvider, ScoresProvider, GameProvider>(
          create: (_) => GameProvider(),
          update: (_, settings, scores, game) => game!..setSettingsProvider(settings)..setScoresProvider(scores),
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
          builder: (context, child) => ColoredBox(color: Colors.black, child: child!),
        );
      },
    );
  }
}
