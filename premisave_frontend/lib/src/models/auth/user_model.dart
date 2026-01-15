enum Role {
  client,
  homeOwner,
  admin,
  operations,
  finance,
  support,
}

class UserModel {
  final String id;
  final String username;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address1;
  final String address2;
  final String country;
  final String language;
  final String profilePictureUrl;
  final Role role;
  final bool verified;
  final bool active;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.address1 = '',
    this.address2 = '',
    this.country = '',
    this.language = 'English',
    this.profilePictureUrl = '',
    required this.role,
    this.verified = false,
    this.active = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'] ?? '',
      country: json['country'] ?? '',
      language: json['language'] ?? 'English',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      role: Role.values.firstWhere(
            (r) => r.name.toUpperCase() == (json['role'] ?? 'CLIENT').toUpperCase(),
        orElse: () => Role.client,
      ),
      verified: json['verified'] ?? false,
      active: json['active'] ?? true,
    );
  }
}