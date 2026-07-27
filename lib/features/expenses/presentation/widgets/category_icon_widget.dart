import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class CategoryIconWidget extends StatelessWidget {
  const CategoryIconWidget({
    required this.iconName,
    required this.colorHex,
    this.size = 48,
    this.fontSize = 24,
    super.key,
  });

  final String iconName;
  final String colorHex;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    Color parseColor(String hex) {
      if (hex.isEmpty) return AppColors.surfaceContainerHigh;
      try {
        final buffer = StringBuffer();
        if (hex.length == 6 || hex.length == 7) buffer.write('ff');
        buffer.write(hex.replaceFirst('#', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (e) {
        return AppColors.surfaceContainerHigh;
      }
    }

    final color = parseColor(colorHex);
    final displayChar = iconName.isNotEmpty ? iconName : '❓';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        displayChar,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}
