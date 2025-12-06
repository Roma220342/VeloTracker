import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Головна бібліотека карт
import 'package:latlong2/latlong.dart'; // Для роботи з координатами

class RouteMap extends StatefulWidget {
  // Ми приймаємо "сирий" список точок з бази даних (JSON)
  final List<dynamic> routeData;

  const RouteMap({super.key, required this.routeData});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final MapController _mapController = MapController();
  List<LatLng> _points = [];
  LatLng _center = const LatLng(50.45, 30.52); // Дефолт (Київ), якщо даних немає

  @override
  void initState() {
    super.initState();
    _parseRoute();
  }

  // Перетворюємо JSON у зрозумілий для карти формат
  void _parseRoute() {
    if (widget.routeData.isEmpty) return;

    try {
      _points = widget.routeData.map((point) {
        return LatLng(
          (point['lat'] as num).toDouble(),
          (point['lng'] as num).toDouble(),
        );
      }).toList();

      if (_points.isNotEmpty) {
        _center = _points.first; // Центруємо на старті
      }
    } catch (e) {
      debugPrint('Error parsing route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Якщо маршруту немає - показуємо сірий квадрат з іконкою
    if (widget.routeData.isEmpty || _points.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: Colors.grey, size: 48),
              SizedBox(height: 8),
              Text("No route data", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: 13.0,
        // Забороняємо обертання карти, щоб не плутати користувача
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        // Коли карта готова - робимо "Zoom to fit"
        onMapReady: () {
          if (_points.isNotEmpty) {
            // Вираховуємо межі маршруту
            final bounds = LatLngBounds.fromPoints(_points);
            // Зумимо камеру під ці межі з відступом
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(40), // Відступ від країв екрану
              ),
            );
          }
        },
      ),
      children: [
        // 1. Шар самої карти (OSM Тайли)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.velotracker', // Важливо для OSM
        ),
        
        // 2. Шар лінії маршруту
        PolylineLayer(
          polylines: [
            Polyline(
              points: _points,
              strokeWidth: 4.0,
              color: Colors.blue, // Колір треку
              borderColor: Colors.blue.withValues(alpha: 0.5),
              borderStrokeWidth: 2.0,
            ),
          ],
        ),

        // 3. Шар маркерів (Старт і Фініш)
        MarkerLayer(
          markers: [
            // Старт (Зелений прапорець)
            Marker(
              point: _points.first,
              width: 40,
              height: 40,
              alignment: Alignment.topCenter,
              child: const Icon(Icons.location_on, color: Colors.green, size: 40),
            ),
            // Фініш (Червоний прапорець)
            Marker(
              point: _points.last,
              width: 40,
              height: 40,
              alignment: Alignment.topCenter,
              child: const Icon(Icons.flag_circle, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}