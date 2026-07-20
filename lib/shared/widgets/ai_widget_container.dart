import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_card.dart';

class AiWidgetContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AiWidgetContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryContainer,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          AppCard(
            padding: padding,
            child: child,
          ),
          const Positioned(
            top: 16,
            right: 16,
            child: Text(
              '✨',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
