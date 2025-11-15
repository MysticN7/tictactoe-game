import 'package:vibration/vibration.dart';

class VibrationService {
  static Future<void> vibrate({int duration = 50}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  static Future<void> vibratePattern() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 50, 100, 50]);
    }
  }
}

