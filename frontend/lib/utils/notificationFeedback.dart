import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class NotificationFeedback {
  NotificationFeedback._();

  static DateTime? _lastPlayedAt;
  static final AudioPlayer _player = AudioPlayer();
  static bool _configured = false;

  static Future<void> play() async {
    final now = DateTime.now();
    if (_lastPlayedAt != null &&
        now.difference(_lastPlayedAt!).inMilliseconds < 800) {
      return;
    }
    _lastPlayedAt = now;
    await _configurePlayer();
    await _player.play(AssetSource('audio/sound.mp3'), volume: 1);
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 160);
    }
  }

  static Future<void> _configurePlayer() async {
    if (_configured) return;
    _configured = true;
    await _player.setReleaseMode(ReleaseMode.stop);
  }
}
