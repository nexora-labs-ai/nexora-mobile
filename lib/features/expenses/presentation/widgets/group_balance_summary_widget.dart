import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../domain/entities/group_balance_entity.dart';

class GroupBalanceSummaryWidget extends StatelessWidget {
  const GroupBalanceSummaryWidget({
    required this.balances,
    required this.members,
    required this.currency,
    super.key,
  });

  final List<GroupBalanceEntity> balances;
  final List<GroupMemberEntity> members;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (balances.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: balances.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final balance = balances[index];
          final member = members.firstWhere(
            (m) => m.userId == balance.userId,
            orElse: () => GroupMemberEntity(
              id: '',
              groupId: '',
              userId: balance.userId,
              role: GroupRole.member,
              joinedAt: DateTime.now(),
              displayName: 'Unknown',
            ),
          );

          final isPositive = balance.balance >= 0;
          final color = isPositive ? AppColors.success : AppColors.error;
          final fmt = NumberFormat.currency(symbol: '', decimalDigits: 0);

          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: member.avatarUrl != null
                      ? NetworkImage(member.avatarUrl!)
                      : null,
                  child: member.avatarUrl == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  member.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : ''}${fmt.format(balance.balance)} $currency',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
