import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  SoundService._();

  static Future<void> playTapSound() => _play('sounds/tap.wav');
  static Future<void> playWinSound() => _play('sounds/win.wav');
  static Future<void> playDrawSound() => _play('sounds/draw.wav');
  static Future<void> playErrorSound() => _play('sounds/error.wav');

  static Future<void> _play(String assetPath) async {
    final player = AudioPlayer(playerId: 'sfx-${DateTime.now().microsecondsSinceEpoch}');
    try {
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource(assetPath));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('SoundService error while playing $assetPath: $error\n$stackTrace');
      }
    } finally {
      await player.dispose();
    }
  }
}
