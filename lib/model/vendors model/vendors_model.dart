class VendorsModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? city;
  final String? phone;
  final String role;
  final bool isEmailVerified;
  final String? ntn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VendorsModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.city,
    this.phone,
    required this.role,
    required this.isEmailVerified,
    this.ntn,
    this.createdAt,
    this.updatedAt,
  });

  factory VendorsModel.fromMap(Map<String, dynamic> json) {
    return VendorsModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      city: json['city'],
      phone: json['phone'] ?? json['phoneNumber'],
      role: json['role'] ?? 'vendor',
      isEmailVerified: (json['isEmailVerified'] ?? false) == true,
      ntn: json['ntn']?.toString(),                                // <-- NEW
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }
}
