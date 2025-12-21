class StatusStory {
  const StatusStory({
    required this.id,
    required this.time,
    this.caption,
    this.imageUrl,
  });

  final String id;
  final DateTime time;
  final String? caption;
  final String? imageUrl;
}

class StatusUpdate {
  const StatusUpdate({
    required this.user,
    required this.initials,
    required this.stories,
    this.avatarUrl,
    this.isMuted = false,
  });

  final String user;
  final String initials;
  final List<StatusStory> stories;
  final String? avatarUrl;
  final bool isMuted;
}
