import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/utils/app_logger.dart'; 

class RouteMap extends StatefulWidget {
  final List<dynamic> routeData;

  const RouteMap({super.key, required this.routeData});

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  final MapController _mapController = MapController();
  List<LatLng> _points = [];
  LatLng _center = const LatLng(50.45, 30.52);

  @override
  void initState() {
    super.initState();
    _parseRoute();
  }

  void _parseRoute() {
    if (widget.routeData.isEmpty) return;

    try {
      _points = widget.routeData.map((point) {
        return LatLng(
          double.tryParse(point['lat'].toString()) ?? 0.0,
          double.tryParse(point['lng'].toString()) ?? 0.0,
        );
      }).toList();

      if (_points.isNotEmpty) {
        _center = _points.first;
      }
    } catch (e) {
      logger.e('Error parsing route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routeData.isEmpty || _points.isEmpty) {
      return Container(
        color: onSurfaceColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: textTertiaryColor, size: 48),
              SizedBox(height: 8),
              Text("No route data", style: TextStyle(color: textTertiaryColor)),
            ],
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        backgroundColor: onSurfaceColor,
        initialCenter: _center,
        initialZoom: 15.0,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: () {
          if (_points.length > 1) {
            try {
              final bounds = LatLngBounds.fromPoints(_points);
              
              if (bounds.north != bounds.south || bounds.east != bounds.west) {
                _mapController.fitCamera(
                  CameraFit.bounds(
                    bounds: bounds,
                    padding: const EdgeInsets.all(40),
                  ),
                );
              }
            } catch (e) {
              logger.e("Zoom error: $e");
            }
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.velotracker',
        ),
        if (_points.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _points,
                strokeWidth: 4.0,
                color: Colors.blue,
                borderColor: Colors.blue.withValues(alpha: 0.5), 
                borderStrokeWidth: 2.0,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: _points.first,
              width: 40,
              height: 40,
              alignment: Alignment.topCenter,
              child: const Icon(Icons.location_on, color: primaryColor, size: 40),
            ),
            if (_points.length > 1)
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