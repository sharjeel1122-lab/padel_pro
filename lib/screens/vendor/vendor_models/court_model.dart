class VendorCourtModel {
  String id;
  String name;
  String location;
  double price;
  bool isApproved;
  List<String> imageUrls;
  String startTime;
  String endTime;

  VendorCourtModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    this.isApproved = false,
    required this.imageUrls,
    required this.startTime,
    required this.endTime,
  });
}
