import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Primary call-to-action button.
///
/// Supports loading, disabled, and outlined variants.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.width,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final Color? color;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    final child = isLoading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isOutlined ? effectiveColor : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(label, style: AppTextStyles.labelLarge),
            ],
          );

    final style = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: effectiveColor,
            side: BorderSide(color: effectiveColor),
            minimumSize: Size(width ?? double.infinity, height),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: AppTextStyles.labelLarge,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: effectiveColor,
            foregroundColor: Colors.white,
            minimumSize: Size(width ?? double.infinity, height),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: AppTextStyles.labelLarge,
          );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed, style: style, child: child)
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: child);
  }
}
