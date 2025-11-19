class RideModel {
  final String id;
  final String title;
  final DateTime date;
  final double distance;
  final String duration;
  final double avgSpeed;

  RideModel({
    required this.id,
    required this.title,
    required this.date,
    required this.distance,
    required this.duration,
    required this.avgSpeed,
  });
}