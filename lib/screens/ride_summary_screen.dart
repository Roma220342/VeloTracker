import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';
import 'package:velotracker/widgets/discard_dialog.dart';
import 'package:velotracker/widgets/stat_item.dart';

class RideSummaryScreen extends StatefulWidget {
  const RideSummaryScreen({super.key});

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  late TextEditingController _nameController;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "Afternoon Ride - Tuesday 17 Oct");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        
        appBar: AppBar(
          leading: const BackButton(),
          elevation: 0,
        ),
        
        body: SafeArea(
          // 1. LayoutBuilder дає нам доступну висоту екрана
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // 2. ConstrainedBox змушує Column бути не меншим за висоту екрана
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  // 3. IntrinsicHeight допомагає коректно працювати Spacer
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- ВМІСТ (ВГОРІ) ---
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Ride Complete!',
                                  style: theme.textTheme.headlineLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You crushed it. Check your final stats below.',
                                  style: theme.textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                
                          // Картка статистики
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: onSurfaceColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Column(
                              children: [
                                Row(
                                  children: [
                                    StatItem(label: 'Distance', value: '25.7', unit: 'km'),
                                    StatItem(label: 'Duration', value: '1:15:32', unit: ''),
                                  ],
                                ),
                                SizedBox(height: 32),
                                Row(
                                  children: [
                                    StatItem(label: 'Avg.Speed', value: '20.3', unit: 'km/h'),
                                    StatItem(label: 'Max.Speed', value: '40.8', unit: 'km/h'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          Text('Ride Name', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(),
                          ),
                          const SizedBox(height: 16),
                          Text('Notes (Optional)', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(hintText: 'Add some notes about the ride'),
                          ),
                
                          // --- 4. РОЗТЯГУВАЧ (Штовхає кнопки вниз) ---
                          const Spacer(),
                          const SizedBox(height: 24),
                
                          // --- КНОПКИ (ВНИЗУ) ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Save logic
                              },
                              child: const Text('Save Ride'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => DiscardDialog(
                                    onConfirm: () {
                                      Navigator.of(context).pop(); 
                                      Navigator.of(context).pop(); 
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
}