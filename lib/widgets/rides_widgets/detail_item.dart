import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart'; 

class DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSmallValue;

  const DetailItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isSmallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: onSurfaceColor, 
        borderRadius: BorderRadius.circular(16),
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
            child: Icon(
              icon,
              color: primaryColor, 
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Назва метрики
          Text(
            label,
            style: theme.textTheme.bodyLarge,
          ),
          
          const Spacer(),
          
          // Значення
          Text(
            value,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}