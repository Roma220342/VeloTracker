import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velotracker/models/ride_model.dart';
import 'package:velotracker/services/ride_service.dart';
import 'package:velotracker/services/settings_service.dart'; // 👇 Імпорт налаштувань
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/widgets/ride_details_widgets/delete_ride_dialog.dart';
import 'package:velotracker/widgets/rides_widgets/detail_item.dart';
import 'package:velotracker/widgets/ride_details_widgets/edit_ride_dialog.dart';
import 'package:velotracker/widgets/ride_details_widgets/route_map.dart'; 

class RideDetailsScreen extends StatefulWidget {
  final RideModel ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final RideService _rideService = RideService();
  late RideModel _displayRide;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _displayRide = widget.ride;
  }

  // --- ЛОГІКА РЕДАГУВАННЯ ---
  Future<void> _onEditPressed() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => EditRideDialog(
        initialTitle: _displayRide.title,
        initialNotes: _displayRide.notes,
      ),
    );

    if (result == null) return; 

    final newTitle = result['title']!;
    final newNotes = result['notes']!;

    if (newTitle == _displayRide.title && newNotes == _displayRide.notes) return;

    final success = await _rideService.updateRide(_displayRide.id, newTitle, newNotes);

    if (success && mounted) {
      setState(() {
        _displayRide = RideModel(
          id: _displayRide.id,
          title: newTitle,
          notes: newNotes,
          date: _displayRide.date,
          distance: _displayRide.distance,
          duration: _displayRide.duration,
          avgSpeed: _displayRide.avgSpeed,
          maxSpeed: _displayRide.maxSpeed,
          routeData: _displayRide.routeData,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride updated!')));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update')));
    }
  }

  // --- ЛОГІКА ВИДАЛЕННЯ ---
  Future<void> _onDeletePressed() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => const DeleteRideDialog(),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);
    final success = await _rideService.deleteRide(_displayRide.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (success) {
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ride deleted')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.45;
    final dateStr = DateFormat('MMMM d, yyyy \'at\' HH:mm').format(_displayRide.date);

    // 👇 Слухаємо зміни налаштувань (KM/Miles)
    return ListenableBuilder(
      listenable: SettingsController(),
      builder: (context, child) {
        final settings = SettingsController();

        // Конвертуємо дані для відображення
        final distVal = settings.convertDistance(_displayRide.distance);
        final avgVal = settings.convertSpeed(_displayRide.avgSpeed);
        final maxVal = settings.convertSpeed(_displayRide.maxSpeed);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text('Ride Details'),
            centerTitle: true,
            leading: const BackButton(),
            actions: [
              if (_isDeleting)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  color: theme.colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (String value) {
                    if (value == 'delete') _onDeletePressed();
                    if (value == 'edit') _onEditPressed();
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: textSecondaryColor),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: errorColor),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: SizedBox( 
                    height: mapHeight,
                    width: double.infinity,
                    child: RouteMap(routeData: _displayRide.routeData), 
                  ),
                ),
                const SizedBox(height: 24),

                Text(_displayRide.title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 24),

                // 👇 Використовуємо конвертовані значення та одиниці виміру
                DetailItem(
                  icon: Icons.straighten, 
                  label: 'Distance', 
                  value: '${distVal.toStringAsFixed(2)} ${settings.distanceUnit}'
                ),
                DetailItem(
                  icon: Icons.timer_outlined, 
                  label: 'Duration', 
                  value: _displayRide.duration
                ),
                DetailItem(
                  icon: Icons.speed, 
                  label: 'Avg Speed', 
                  value: '${avgVal.toStringAsFixed(1)} ${settings.speedUnit}'
                ),
                DetailItem(
                  icon: Icons.rocket_launch_outlined, 
                  label: 'Max Speed', 
                  value: '${maxVal.toStringAsFixed(1)} ${settings.speedUnit}'
                ),
                DetailItem(
                  icon: Icons.calendar_today_outlined, 
                  label: 'Date', 
                  value: dateStr, 
                  isSmallValue: true
                ),

                const SizedBox(height: 24),

                if (_displayRide.notes.isNotEmpty) ...[ 
                   Text('Notes', style: theme.textTheme.bodyLarge),
                   const SizedBox(height: 8),
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(color: onSurfaceColor, borderRadius: BorderRadius.circular(15)),
                     child: Text(_displayRide.notes, style: theme.textTheme.bodyLarge),
                   ),
                ],
                
                SizedBox(height: screenHeight * 0.037),
              ],
            ),
          ),
        );
      }
    );
  }
}