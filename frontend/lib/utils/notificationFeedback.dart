import 'package:flutter/services.dart';

class NotificationFeedback {
  NotificationFeedback._();

  static DateTime? _lastPlayedAt;

  static Future<void> play() async {
    final now = DateTime.now();
    if (_lastPlayedAt != null &&
        now.difference(_lastPlayedAt!).inMilliseconds < 800) {
      return;
    }
    _lastPlayedAt = now;
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.click);
  }
}
