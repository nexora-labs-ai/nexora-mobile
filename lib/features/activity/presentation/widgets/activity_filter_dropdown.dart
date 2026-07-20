import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ActivityFilterDropdown extends StatelessWidget {
  const ActivityFilterDropdown({
    required this.selectedGroupId,
    required this.onChanged,
    super.key,
  });

  final String? selectedGroupId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // In a real app, this list would come from a GroupsCubit or Repository
    final mockGroups = [
      {'id': null, 'name': 'All Groups'},
      {'id': '1', 'name': 'Da Nang Trip'},
      {'id': '2', 'name': 'Japan Trip'},
      {'id': '3', 'name': 'Company Retreat'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedGroupId,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.onSurface),
          onChanged: onChanged,
          items: mockGroups.map((group) {
            return DropdownMenuItem<String?>(
              value: group['id'],
              child: Text(group['name']!),
            );
          }).toList(),
        ),
      ),
    );
  }
}
