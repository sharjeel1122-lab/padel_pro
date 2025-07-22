class VendorModel {
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? ntn;


  VendorModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.ntn,

  });
}
