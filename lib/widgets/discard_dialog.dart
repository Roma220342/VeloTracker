import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';

class DiscardDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DiscardDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text(
              'Discard This Ride?',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'All data from this trip will be deleted. Are you sure you want to continue?',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: onConfirm,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: errorContainerColor,
                        foregroundColor: errorColor,
                        side: const BorderSide(color: errorColor),
                      ),
                      child: const Text('Exit'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
