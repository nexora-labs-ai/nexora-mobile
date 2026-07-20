import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_utils.dart';
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
      height: 140,
      margin: const EdgeInsets.only(bottom: 24),
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
          final color =
              isPositive ? AppColors.primaryContainer : AppColors.error;
          final amount = minorUnitsToDouble(balance.balance).abs();
          final hasDecimals = amount.truncateToDouble() != amount;
          final decimalDigits = currency == 'VND' ? 0 : (hasDecimals ? 2 : 0);
          final fmt =
              NumberFormat.currency(symbol: '', decimalDigits: decimalDigits);

          return Container(
            width: 150,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: member.avatarUrl != null
                      ? NetworkImage(member.avatarUrl!)
                      : null,
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: member.avatarUrl == null
                      ? Icon(Icons.person, size: 24, color: color)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  member.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isPositive ? '+' : '-'}${fmt.format(amount)} $currency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
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
