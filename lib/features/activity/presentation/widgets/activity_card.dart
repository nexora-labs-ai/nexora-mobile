import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/activity_entity.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({required this.activity, super.key});

  final ActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(activity.groupAvatar, Icons.group),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    activity.groupName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  _formatTimeAgo(activity.createdAt),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(activity.userAvatar, Icons.person),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                          ),
                          children: [
                            TextSpan(
                              text: '${activity.userName} ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: _getActivityText(activity.type)),
                          ],
                        ),
                      ),
                      if (activity.amount != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '\$${activity.amount!.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                if (activity.statusBadge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.statusBadge!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onErrorContainer,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? url, IconData fallbackIcon) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.primaryContainer,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? Icon(fallbackIcon, size: 14, color: AppColors.onPrimaryContainer)
          : null,
    );
  }

  String _getActivityText(ActivityType type) {
    switch (type) {
      case ActivityType.expenseCreated:
        return 'added a new expense';
      case ActivityType.expenseUpdated:
        return 'updated an expense';
      case ActivityType.expenseDeleted:
        return 'deleted an expense';
      case ActivityType.settlementCompleted:
        return 'completed a settlement';
      case ActivityType.memberJoined:
        return 'joined the group';
      case ActivityType.memberLeft:
        return 'left the group';
      case ActivityType.tripCreated:
        return 'created a new trip';
      case ActivityType.itineraryUpdated:
        return 'updated the itinerary';
      case ActivityType.aiRecommendationGenerated:
        return 'generated AI recommendations';
      case ActivityType.budgetWarning:
        return 'exceeded the budget limit';
      case ActivityType.votingStarted:
        return 'started a new poll';
      case ActivityType.votingClosed:
        return 'closed a poll';
      case ActivityType.unknown:
        return 'performed an action';
    }
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
