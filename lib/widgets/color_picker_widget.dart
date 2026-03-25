import 'package:flutter/material.dart';

/// Widget color picker untuk memilih warna card jadwal
class ColorPickerWidget extends StatelessWidget {
  final Color selected;
  final List<Color> colors;
  final ValueChanged<Color> onSelected;

  const ColorPickerWidget({
    super.key,
    required this.selected,
    required this.colors,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) {
        final isSelected = selected.toARGB32() == color.toARGB32();
        return GestureDetector(
          onTap: () => onSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 18, color: Colors.black54)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
