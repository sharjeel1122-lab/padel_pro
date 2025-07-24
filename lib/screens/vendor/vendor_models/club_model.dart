class Club {
  final String id;
  final String name;
  final String vendorId;

  Club({
    required this.id,
    required this.name,
    required this.vendorId,
  });

  factory Club.fromMap(Map<String, dynamic> data) => Club(
    id: data['id'],
    name: data['name'],
    vendorId: data['vendorId'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'vendorId': vendorId,
  };
}
