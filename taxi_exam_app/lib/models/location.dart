class Location {
  final int id;
  final String name;
  final String district;
  final String category;
  final double? latitude;
  final double? longitude;

  Location({
    required this.id,
    required this.name,
    required this.district,
    required this.category,
    this.latitude,
    this.longitude,
  });

  factory Location.fromString(int id, String name, String district, String category) {
    return Location(
      id: id,
      name: name,
      district: district,
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      district: json['district'],
      category: json['category'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}