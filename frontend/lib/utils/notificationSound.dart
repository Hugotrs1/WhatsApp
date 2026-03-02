import 'package:audioplayers/audioplayers.dart';

class NotificationSound {
  NotificationSound._();

  static final AudioPlayer _player = AudioPlayer();
  static DateTime? _lastPlayedAt;

  static Future<void> playNotification() async {
    final now = DateTime.now();
    if (_lastPlayedAt != null &&
        now.difference(_lastPlayedAt!).inMilliseconds < 800) {
      return;
    }
    _lastPlayedAt = now;
    await _player.play(
      AssetSource('audio/discord.mp3'),
      volume: 1,
    );
  }
}

