class Venue {
  final String id;
  final String clubId;
  final String name;
  final String imageUrl;
  final String peakStart;
  final String peakEnd;
  final String offPeakStart;
  final String offPeakEnd;

  Venue({
    required this.id,
    required this.clubId,
    required this.name,
    required this.imageUrl,
    required this.peakStart,
    required this.peakEnd,
    required this.offPeakStart,
    required this.offPeakEnd,
  });

  factory Venue.fromMap(Map<String, dynamic> data) => Venue(
    id: data['id'],
    clubId: data['clubId'],
    name: data['name'],
    imageUrl: data['imageUrl'],
    peakStart: data['peakStart'],
    peakEnd: data['peakEnd'],
    offPeakStart: data['offPeakStart'],
    offPeakEnd: data['offPeakEnd'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'clubId': clubId,
    'name': name,
    'imageUrl': imageUrl,
    'peakStart': peakStart,
    'peakEnd': peakEnd,
    'offPeakStart': offPeakStart,
    'offPeakEnd': offPeakEnd,
  };
}
