import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../domain/entities/group_entity.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({required this.group, super.key, this.onTap});

  final GroupEntity group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _EventTypeIcon(eventType: group.eventType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people_outline,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${group.memberCount} members',
                            style: AppTextStyles.bodySmall),
                        if (group.eventDateStart != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.calendar_today_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd').format(group.eventDateStart!),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (group.hasTargetBudget) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(group.budgetUsedPercent * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: group.budgetUsedPercent > 0.9
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 48,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: group.budgetUsedPercent,
                          minHeight: 6,
                          color: group.budgetUsedPercent > 0.9
                              ? AppColors.error
                              : AppColors.primary,
                          backgroundColor: AppColors.surfaceLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventTypeIcon extends StatelessWidget {
  const _EventTypeIcon({required this.eventType});

  final GroupEventType eventType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_icon, color: _color, size: 24),
    );
  }

  IconData get _icon => switch (eventType) {
        GroupEventType.trip => Icons.flight_outlined,
        GroupEventType.workshop => Icons.computer_outlined,
        GroupEventType.party => Icons.celebration_outlined,
        GroupEventType.hackathon => Icons.code_outlined,
        GroupEventType.other => Icons.group_outlined,
      };

  Color get _color => switch (eventType) {
        GroupEventType.trip => AppColors.info,
        GroupEventType.workshop => AppColors.accent,
        GroupEventType.party => AppColors.secondary,
        GroupEventType.hackathon => AppColors.primary,
        GroupEventType.other => AppColors.textSecondary,
      };
}
