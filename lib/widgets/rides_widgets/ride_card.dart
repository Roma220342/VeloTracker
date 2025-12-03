import 'package:flutter/material.dart';
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
              decoration: BoxDecoration(
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
                    '${ride.distance} km · ${ride.avgSpeed} km/h · ${ride.duration}',
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
}
