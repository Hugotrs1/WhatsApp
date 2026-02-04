import 'userSummary.dart';

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.status,
    required this.requesterId,
    required this.recipientId,
    this.requester,
  });

  final String id;
  final String status;
  final String? requesterId;
  final String? recipientId;
  final UserSummary? requester;

  bool get isPending => status.toUpperCase() == 'PENDING';

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    final requesterMap = map['requester'];
    return FriendRequest(
      id: map['id']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      requesterId: map['requester_id']?.toString(),
      recipientId: map['recipient_id']?.toString(),
      requester: requesterMap is Map<String, dynamic> ? UserSummary.fromMap(requesterMap) : null,
    );
  }
}
