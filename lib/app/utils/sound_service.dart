import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> playTapSound() async {
    await _audioPlayer.play(AssetSource('sounds/tap.wav'));
  }

  static Future<void> playWinSound() async {
    await _audioPlayer.play(AssetSource('sounds/win.wav'));
  }

  static Future<void> playDrawSound() async {
    await _audioPlayer.play(AssetSource('sounds/draw.wav'));
  }

  static Future<void> playErrorSound() async {
    await _audioPlayer.play(AssetSource('sounds/error.wav'));
  }
}
