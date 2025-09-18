class TaxiRoute {
  final int id;
  final String startPoint;
  final String endPoint;
  final List<String> routeSegments;

  TaxiRoute({
    required this.id,
    required this.startPoint,
    required this.endPoint,
    required this.routeSegments,
  });

  factory TaxiRoute.fromString(int id, String start, String end, String routeDescription) {
    final segments = routeDescription.split('、').map((s) => s.trim()).toList();
    return TaxiRoute(
      id: id,
      startPoint: start,
      endPoint: end,
      routeSegments: segments,
    );
  }

  String get routeDescription => routeSegments.join('、');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startPoint': startPoint,
      'endPoint': endPoint,
      'routeSegments': routeSegments,
    };
  }

  factory TaxiRoute.fromJson(Map<String, dynamic> json) {
    return TaxiRoute(
      id: json['id'],
      startPoint: json['startPoint'],
      endPoint: json['endPoint'],
      routeSegments: List<String>.from(json['routeSegments']),
    );
  }
}