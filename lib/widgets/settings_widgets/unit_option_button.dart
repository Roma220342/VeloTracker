import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart'; 
class UnitOptionButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const UnitOptionButton({
    super.key,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque, 
        child: Container(
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 16,
              color: isActive ? Colors.white : textSecondaryColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}