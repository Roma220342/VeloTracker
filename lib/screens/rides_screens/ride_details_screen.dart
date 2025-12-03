import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/widgets/rides_widgets/detail_item.dart'; 

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.35;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      
      appBar: AppBar(
        title: const Text('Ride Details'),
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          // Меню дій (Edit/Delete)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (String value) {
              // TODO: Handle actions
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
            // 1. КАРТА (Статична заглушка)
           ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: SizedBox( 
                height: mapHeight,
                width: double.infinity,
                child: Image.asset(
                  'assets/icons/map.png',
                  fit: BoxFit.cover, 
                ),
              ),
            ),
           SizedBox(height: 24),

            // 2. НАЗВА ПОЇЗДКИ
            Text(
              'Morning Lake Loop',
              style: theme.textTheme.headlineMedium, // H2 Bold
            ),

            const SizedBox(height: 24),

            // 3. СПИСОК МЕТРИК 
            const DetailItem(
              icon: Icons.straighten, 
              label: 'Distance', 
              value: '45,53 km'
            ),
            const DetailItem(
              icon: Icons.timer_outlined, 
              label: 'Duration', 
              value: '1:30:43'
            ),
            const DetailItem(
              icon: Icons.speed, 
              label: 'Avg Speed', 
              value: '30,12 km/h'
            ),
            const DetailItem(
              icon: Icons.rocket_launch_outlined, 
              label: 'Max Speed', 
              value: '53,25 km/h'
            ),
            const DetailItem(
              icon: Icons.calendar_today_outlined, 
              label: 'Date', 
              value: 'October 27, 2025 at 12:45',
              isSmallValue: true, 
            ),

            const SizedBox(height: 24),

            // 4. НОТАТКИ
            Text('Notes', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: onSurfaceColor, 
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'TOP Weather conditions',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            SizedBox(height: screenHeight * 0.037),
          ],
        ),
      ),
    );
  }
}