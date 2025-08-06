enum RequestType { vendor, venue }

class RequestModel {
  final String id;
  final String name;
  final String details;
  final RequestType type;

  RequestModel({
    required this.id,
    required this.name,
    required this.details,
    required this.type,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['_id'],
      name: "${json['firstName']} ${json['lastName']}",
      details: "${json['city']} - ${json['email']}",
      type: RequestType.vendor,
    );
  }
}
