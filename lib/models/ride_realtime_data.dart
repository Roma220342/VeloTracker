class RideRealtimeData {
  final Duration duration;
  final double distanceKm;
  final double currentSpeed;

  RideRealtimeData({
    required this.duration,
    required this.distanceKm,
    required this.currentSpeed,
  });

  factory RideRealtimeData.initial() {
    return RideRealtimeData(
      duration: Duration.zero,
      distanceKm: 0,
      currentSpeed: 0,
    );
  }
}