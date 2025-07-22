// models/request_model.dart
enum RequestType { venue, vendor }

class RequestModel {
  final String name;
  final String details;
  final RequestType type;

  RequestModel({
    required this.name,
    required this.details,
    required this.type,
  });
}
