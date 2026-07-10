import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/enums/app_enums.dart';
import '../bloc/settlement_bloc.dart';

class SettlementHistoryView extends StatelessWidget {
  const SettlementHistoryView({
    required this.state,
    required this.userNames,
    required this.currentUserId,
    super.key,
  });

  final SettlementLoaded state;
  final Map<String, String> userNames;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final history = state.settlements;
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded,
                size: 80, color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No History Yet',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Completed settlements will appear here.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final isPending = item.status == SettlementStatus.pending;
        final fromName = userNames[item.fromUserId] ?? 'Unknown';
        final toName = userNames[item.toUserId] ?? 'Unknown';

        Color statusColor;
        switch (item.status) {
          case SettlementStatus.completed:
            statusColor = Colors.green;
            break;
          case SettlementStatus.cancelled:
            statusColor = Colors.red;
            break;
          case SettlementStatus.pending:
            statusColor = Colors.orange;
            break;
        }

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.status == SettlementStatus.completed
                        ? Icons.check_circle
                        : (item.status == SettlementStatus.cancelled
                            ? Icons.cancel
                            : Icons.access_time_filled),
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$fromName paid $toName',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('\$${formatMinorUnits(item.amount)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.status.name.toUpperCase(),
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (item.evidenceUrl != null)
                  IconButton(
                    icon: const Icon(Icons.receipt_long, color: Colors.blue),
                    tooltip: 'View Evidence',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(item.evidenceUrl!),
                          ),
                        ),
                      );
                    },
                  ),
                if (isPending) ...[
                  if (item.toUserId == currentUserId)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green, size: 32),
                          onPressed: () {
                            context
                                .read<SettlementBloc>()
                                .add(CompleteSettlement(item.id));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel,
                              color: Colors.red, size: 32),
                          onPressed: () {
                            context
                                .read<SettlementBloc>()
                                .add(CancelSettlement(item.id));
                          },
                        ),
                      ],
                    )
                  else if (item.fromUserId == currentUserId)
                    TextButton.icon(
                      icon:
                          const Icon(Icons.close, color: Colors.red, size: 18),
                      label: const Text('Cancel',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        context
                            .read<SettlementBloc>()
                            .add(CancelSettlement(item.id));
                      },
                    ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
