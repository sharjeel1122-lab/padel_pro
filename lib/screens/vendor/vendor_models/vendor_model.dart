class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isApproved;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.isApproved = false, required String status,
  });
}
