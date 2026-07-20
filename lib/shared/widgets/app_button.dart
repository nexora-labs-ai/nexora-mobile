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
    this.isFullWidth = true,
    this.icon,
    this.color,
    this.width,
    this.height = 52,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isFullWidth;
  final Widget? icon;
  final Color? color;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(label, style: AppTextStyles.bodyLarge),
            ],
          );

    final btnWidth = isFullWidth ? (width ?? double.infinity) : width;

    final style = isOutlined
        ? OutlinedButton.styleFrom(
            padding: padding,
            foregroundColor: effectiveColor,
            side: BorderSide(color: effectiveColor),
            minimumSize:
                btnWidth != null ? Size(btnWidth, height) : Size(0, height),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: AppTextStyles.bodyLarge,
          )
        : ElevatedButton.styleFrom(
            padding: padding,
            backgroundColor: effectiveColor,
            foregroundColor: Colors.white,
            minimumSize:
                btnWidth != null ? Size(btnWidth, height) : Size(0, height),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: AppTextStyles.bodyLarge,
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
