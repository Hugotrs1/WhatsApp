import '../utils/utils.dart';
import 'friendRequest.dart';

class UserRelation {
  const UserRelation({
    required this.isFriend,
    this.incomingRequest,
    this.outgoingRequest,
  });

  final bool isFriend;
  final FriendRequest? incomingRequest;
  final FriendRequest? outgoingRequest;

  bool get hasIncomingPending => incomingRequest?.isPending == true;
  bool get hasOutgoingPending => outgoingRequest?.isPending == true;

  factory UserRelation.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserRelation(isFriend: false);
    }
    final incoming = map['incoming_request'];
    final outgoing = map['outgoing_request'];
    return UserRelation(
      isFriend: map['is_friend'] == true,
      incomingRequest:
          incoming is Map<String, dynamic> ? FriendRequest.fromMap(incoming) : null,
      outgoingRequest:
          outgoing is Map<String, dynamic> ? FriendRequest.fromMap(outgoing) : null,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.phoneMasked,
    required this.relation,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String phoneMasked;
  final UserRelation relation;

  String get displayName => buildDisplayName(firstName: firstName, lastName: lastName);
  String get displayPhone => phone.isNotEmpty ? phone : phoneMasked;
  String get initials => initialsFromName(displayName);

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final relationMap = map['relation'];
    return UserProfile(
      id: map['id']?.toString() ?? '',
      firstName: map['first_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      phoneMasked: map['phone_masked']?.toString() ?? '',
      relation: UserRelation.fromMap(
        relationMap is Map<String, dynamic> ? relationMap : null,
      ),
    );
  }
}
