import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';

// Цей віджет малює зелений перемикач "All / Week / Month"
class SlidingSegmentedControl extends StatelessWidget {
  final int selectedIndex; // Який пункт зараз обрано (0, 1 або 2)
  final Function(int) onValueChanged; // Функція, що повідомляє батьківському екрану про клік
  final List<String> values; // Список назв кнопок (наприклад, ['All', 'Week'])

  const SlidingSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onValueChanged,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsCount = values.length;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: onSurfaceColor, 
        borderRadius: BorderRadius.circular(50),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Рахуємо ширину однієї кнопки
          final double segmentWidth = constraints.maxWidth / itemsCount;

          return Stack(
            children: [
              // Анімований фон
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                // Позиція зліва залежить від номера обраної кнопки
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary, 
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              
              // 2.текст кнопки
              Row(
                children: List.generate(itemsCount, (index) {
                  return _buildSingleTab(context, values[index], index);
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  // Малює одну прозору кнопку з текстом
  Widget _buildSingleTab(BuildContext context, String text, int index) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => onValueChanged(index), // Повідомляємо про клік
        behavior: HitTestBehavior.opaque, // Щоб клік ловився по всій площі
        child: Container(
          alignment: Alignment.center,
          // Анімуємо колір тексту 
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: theme.textTheme.bodyMedium!.copyWith(
              color: isSelected ? Colors.white : textSecondaryColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}