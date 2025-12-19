enum CallDirection { incoming, outgoing }

class CallEntry {
  const CallEntry({
    required this.id,
    required this.contact,
    required this.time,
    this.isVideo = false,
    this.direction = CallDirection.incoming,
    this.missed = false,
    this.avatarUrl,
  });

  final String id;
  final String contact;
  final DateTime time;
  final bool isVideo;
  final CallDirection direction;
  final bool missed;
  final String? avatarUrl;
}
