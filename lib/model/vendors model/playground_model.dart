// class Playground {
//   String? id;
//   String name;
//   String size;
//   String openingTime;
//   String closingTime;
//   String description;
//   List<String> photos;
//   String? website;
//   String? phoneNumber;
//   String location;
//   String city;
//   List<String> facilities;
//   bool recommended;
//   String vendorId;
//   List<Court> courts;
//
//   Playground({
//     this.id,
//     required this.name,
//     required this.size,
//     required this.openingTime,
//     required this.closingTime,
//     required this.description,
//     required this.photos,
//     this.website,
//     this.phoneNumber,
//     required this.location,
//     required this.city,
//     required this.facilities,
//     this.recommended = false,
//     required this.vendorId,
//     required this.courts,
//   });
//
// // Add fromJson and toJson methods
// }
//
// class Court {
//   String courtNumber;
//   List<String> courtType;
//   List<Pricing> pricing;
//   List<PeakHours> peakHours;
//   bool isActive;
//
//   Court({
//     required this.courtNumber,
//     required this.courtType,
//     required this.pricing,
//     required this.peakHours,
//     this.isActive = true,
//   });
//
// // Add fromJson and toJson methods
// }
//
// class Pricing {
//   int duration;
//   double price;
//
//   Pricing({
//     required this.duration,
//     required this.price,
//   });
//
// // Add fromJson and toJson methods
// }
//
// class PeakHours {
//   String startTime;
//   String endTime;
//   double price;
//
//   PeakHours({
//     required this.startTime,
//     required this.endTime,
//     required this.price,
//   });
//
// // Add fromJson and toJson methods
// }

class Playground {
  String name, size, description, town,openingTime, closingTime, phoneNumber, location, city, website;
  List<String> facilities;
  List<Court> courts;

  Playground({
    required this.name,
    required this.size,
    required this.description,
    required this.openingTime,
    required this.closingTime,
    required this.phoneNumber,
    required this.location,
    required this.city,
    required this.town,
    this.website = "",
    required this.facilities,
    required this.courts,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "size": size,
    "description": description,
    "openingTime": openingTime,
    "closingTime": closingTime,
    "phoneNumber": phoneNumber,
    "location": location,
    "city": city,
    "website": website,
    "town":town,
    "facilities": facilities,
    "courts": courts.map((c) => c.toJson()).toList(),
  };
}


// class Playground {
//   String name, size, description, openingTime, closingTime, phoneNumber, location, city, website;
//   List<String> facilities;
//   List<Court> courts;
//
//   Playground({
//     required this.name,
//     required this.size,
//     required this.description,
//     required this.openingTime,
//     required this.closingTime,
//     required this.phoneNumber,
//     required this.location,
//     required this.city,
//     this.website = "",
//     required this.facilities,
//     required this.courts,
//   });
//
//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "size": size,
//     "description": description,
//     "openingTime": openingTime,
//     "closingTime": closingTime,
//     "phoneNumber": phoneNumber,
//     "location": location,
//     "city": city,
//     "website": website,
//     "facilities": facilities,
//     "courts": courts.map((c) => c.toJson()).toList(),
//   };
// }

class Court {
  String courtNumber;
  List<String> courtType;
  List<Pricing> pricing;
  List<PeakHour> peakHours;

  Court({
    required this.courtNumber,
    required this.courtType,
    required this.pricing,
    required this.peakHours,
  });

  Map<String, dynamic> toJson() => {
    "courtNumber": courtNumber,
    "courtType": courtType,
    "pricing": pricing.map((p) => p.toJson()).toList(),
    "peakHours": peakHours.map((p) => p.toJson()).toList(),
  };
}

class Pricing {
  int duration;
  double price;

  Pricing({required this.duration, required this.price});

  Map<String, dynamic> toJson() => {
    "duration": duration,
    "price": price,
  };
}

class PeakHour {
  String startTime, endTime;
  double price;

  PeakHour({
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    "startTime": startTime,
    "endTime": endTime,
    "price": price,
  };
}
