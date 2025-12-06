class RideModel {
  final String id;
  final String title;
  final DateTime date;
  final double distance;
  final String duration;
  final double avgSpeed;
  final double maxSpeed;
  final List<dynamic> routeData;
  final String notes;

  RideModel({
    required this.id,
    required this.title,
    required this.date,
    required this.distance,
    required this.duration,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.routeData,
    required this.notes,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      
      title: json['title'] ?? 'Ride',
      
      notes: json['notes']?.toString() ?? '',
      
      date: DateTime.tryParse(json['start_time']?.toString() ?? '') ?? DateTime.now(),
   
      distance: double.tryParse(json['distance']?.toString() ?? json['distance_km']?.toString() ?? '') ?? 0.0,
      
      duration: json['duration']?.toString() ?? '00:00:00',
      
      avgSpeed: double.tryParse(json['avg_speed']?.toString() ?? '') ?? 0.0,
      
      maxSpeed: double.tryParse(json['max_speed']?.toString() ?? '') ?? 0.0,
  
      routeData: _parseRouteData(json['route_data']),
    );
  }

  // Допоміжний метод для маршруту
  static List<dynamic> _parseRouteData(dynamic rawRoute) {
    if (rawRoute == null) return [];
    if (rawRoute is List) return rawRoute;
    if (rawRoute is String) {
      try {
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}