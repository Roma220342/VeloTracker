import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velotracker/main.dart';
import 'package:velotracker/services/ride_service.dart';
import 'package:velotracker/services/settings_service.dart'; // 👇 Імпорт налаштувань
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/widgets/tracks_widgets/discard_dialog.dart';
import 'package:velotracker/widgets/tracks_widgets/stat_item.dart';

class RideSummaryScreen extends StatefulWidget {
  final double distanceKm;
  final Duration duration;
  final double avgSpeed;
  final double maxSpeed;
  final List<Map<String, double>> routePoints;
  final DateTime startTime;

  const RideSummaryScreen({
    super.key,
    required this.distanceKm,
    required this.duration,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.routePoints,
    required this.startTime,
  });

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  final RideService _rideService = RideService();
  late TextEditingController _nameController;
  final TextEditingController _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _generateDefaultTitle());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generateDefaultTitle() {
    final now = widget.startTime;
    final dateStr = DateFormat('EEEE d MMM').format(now);
    final hour = now.hour;
    String period = 'Ride';

    if (hour < 12) {
      period = 'Morning Ride';
    } else if (hour < 17) {
      period = 'Afternoon Ride';
    } else {
      period = 'Evening Ride';
    }

    return "$period - $dateStr";
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return "${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
    } else {
      return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
    }
  }

  Future<void> _saveRide() async {
    setState(() => _isSaving = true);

    // ВАЖЛИВО: На сервер відправляємо оригінальні дані (в км), 
    // незалежно від того, що вибрав користувач.
    final success = await _rideService.saveRide(
      title: _nameController.text.trim().isEmpty ? "My Ride" : _nameController.text.trim(),
      notes: _notesController.text.trim(),
      distance: widget.distanceKm, 
      duration: _formatDuration(widget.duration),
      avgSpeed: widget.avgSpeed,
      maxSpeed: widget.maxSpeed,
      routePoints: widget.routePoints,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // 👇 Слухаємо налаштування для відображення
    return ListenableBuilder(
      listenable: SettingsController(),
      builder: (context, child) {
        final settings = SettingsController();

        // Конвертуємо для відображення
        final distVal = settings.convertDistance(widget.distanceKm);
        final avgVal = settings.convertSpeed(widget.avgSpeed);
        final maxVal = settings.convertSpeed(widget.maxSpeed);
        
        final timeStr = _formatDuration(widget.duration);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              leading: const BackButton(),
              elevation: 0,
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Ride Complete',
                                      style: theme.textTheme.headlineLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Check your final stats below',
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: onSurfaceColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        StatItem(
                                          label: 'Distance', 
                                          value: distVal.toStringAsFixed(2), // Конвертоване
                                          unit: settings.distanceUnit
                                        ),
                                        StatItem(label: 'Duration', value: timeStr, unit: ''),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    Row(
                                      children: [
                                        StatItem(
                                          label: 'Avg.Speed', 
                                          value: avgVal.toStringAsFixed(1), // Конвертоване
                                          unit: settings.speedUnit
                                        ),
                                        StatItem(
                                          label: 'Max.Speed', 
                                          value: maxVal.toStringAsFixed(1), // Конвертоване
                                          unit: settings.speedUnit
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // ... (далі все без змін: поля вводу, кнопки) ...
                              const SizedBox(height: 32),
                              Text('Ride Name', style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(hintText: 'Enter a name for your ride'),
                              ),
                              const SizedBox(height: 16),
                              Text('Notes (Optional)', style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(hintText: 'Add some notes about the ride'),
                              ),
                              const Spacer(),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveRide,
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(color: Colors.white),
                                        )
                                      : const Text('Save Ride'),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => DiscardDialog(
                                              onConfirm: () {
                                                Navigator.of(context).pushAndRemoveUntil(
                                                  MaterialPageRoute(builder: (context) => const MainScreen()),
                                                  (route) => false,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                  child: const Text('Discard Ride'),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.037),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }
    );
  }
}