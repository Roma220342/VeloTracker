import 'package:flutter/material.dart';
import 'package:velotracker/services/settings_service.dart'; // 👇 Імпорт налаштувань
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/models/ride_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class RideCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onTap;

  const RideCard({
    super.key,
    required this.ride,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMMM d, yyyy \'at\' HH:mm').format(ride.date);

    return ListenableBuilder(
      listenable: SettingsController(),
      builder: (context, child) {
        final settings = SettingsController();

        final dist = settings.convertDistance(ride.distance).toStringAsFixed(2);
        final speed = settings.convertSpeed(ride.avgSpeed).toStringAsFixed(1);
        final unitD = settings.distanceUnit; 
        final unitS = settings.speedUnit;   
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: onSurfaceColor,
              borderRadius: BorderRadius.circular(25),
            ),

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  width: 40,
                  height: 40, 
                  decoration: const BoxDecoration(
                    color: primaryContainerColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/logo_rides_screen.svg',
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.title,
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(height: 4),
                      
                      Text(
                        '$dist $unitD · $speed $unitS · ${ride.duration}',
                        style: theme.textTheme.bodyLarge,
                      ),

                      Text(
                        dateStr,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: textSecondaryColor,
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}