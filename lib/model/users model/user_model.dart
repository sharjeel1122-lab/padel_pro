class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? city;
  final String? phone;
  final String role;
  final bool isEmailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.city,
    this.phone,
    required this.role,
    required this.isEmailVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? json['id']).toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      city: json['city'],
      phone: json['phone'],
      role: json['role'] ?? 'user',
      isEmailVerified: (json['isEmailVerified'] ?? false) == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}
