import 'package:flutter/material.dart';

class EditRideDialog extends StatefulWidget {
  final String initialTitle;
  final String initialNotes;

  const EditRideDialog({
    super.key,
    required this.initialTitle,
    required this.initialNotes,
  });

  @override
  State<EditRideDialog> createState() => _EditRideDialogState();
}

class _EditRideDialogState extends State<EditRideDialog> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialTitle);
    _notesController = TextEditingController(text: widget.initialNotes);
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
              'Edit Ride',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 24), 

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ride Name', style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Enter a name for your ride',
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Notes', style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Add some notes about the ride',
              ),
            ),
            
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'title': _nameController.text.trim(),
                          'notes': _notesController.text.trim(),
                        });
                      },
                      child: const Text('Save'),
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