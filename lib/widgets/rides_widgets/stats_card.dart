import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(      
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: onSurfaceColor,
        borderRadius: BorderRadius.circular(25),
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge,
            maxLines: 1,           
          ),

          const SizedBox(height: 8),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: primaryColor,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
