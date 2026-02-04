import '../utils/utils.dart';

class UserSummary {
  const UserSummary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.phoneMasked,
    required this.isFriend,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String phoneMasked;
  final bool isFriend;

  String get displayName => buildDisplayName(firstName: firstName, lastName: lastName);
  String get displayPhone => phone.isNotEmpty ? phone : phoneMasked;
  String get initials => initialsFromName(displayName);
  String get phoneDigits => normalizeDigits(displayPhone);

  factory UserSummary.fromMap(Map<String, dynamic> map) {
    return UserSummary(
      id: map['id']?.toString() ?? '',
      firstName: map['first_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      phoneMasked: map['phone_masked']?.toString() ?? '',
      isFriend: map['is_friend'] == true,
    );
  }
}
