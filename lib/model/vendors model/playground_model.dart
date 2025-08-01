class Playground {
  String? id;
  String name;
  String size;
  String openingTime;
  String closingTime;
  String description;
  List<String> photos;
  String? website;
  String? phoneNumber;
  String location;
  String city;
  List<String> facilities;
  bool recommended;
  String vendorId;
  List<Court> courts;

  Playground({
    this.id,
    required this.name,
    required this.size,
    required this.openingTime,
    required this.closingTime,
    required this.description,
    required this.photos,
    this.website,
    this.phoneNumber,
    required this.location,
    required this.city,
    required this.facilities,
    this.recommended = false,
    required this.vendorId,
    required this.courts,
  });

// Add fromJson and toJson methods
}

class Court {
  String courtNumber;
  List<String> courtType;
  List<Pricing> pricing;
  List<PeakHours> peakHours;
  bool isActive;

  Court({
    required this.courtNumber,
    required this.courtType,
    required this.pricing,
    required this.peakHours,
    this.isActive = true,
  });

// Add fromJson and toJson methods
}

class Pricing {
  int duration;
  double price;

  Pricing({
    required this.duration,
    required this.price,
  });

// Add fromJson and toJson methods
}

class PeakHours {
  String startTime;
  String endTime;
  double price;

  PeakHours({
    required this.startTime,
    required this.endTime,
    required this.price,
  });

// Add fromJson and toJson methods
}