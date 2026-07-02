import 'package:flutter/material.dart';
import '../../../../../core/utils/currency_utils.dart';

import '../../../../../shared/enums/app_enums.dart';
import '../../../groups/domain/entities/group_entity.dart';

class ExpenseSplitWidget extends StatefulWidget {
  const ExpenseSplitWidget({
    required this.splitType,
    required this.onSplitsChanged,
    required this.members,
    required this.amountController,
    super.key,
  });

  final ExpenseSplitType splitType;
  final ValueChanged<List<Map<String, dynamic>>> onSplitsChanged;
  final List<GroupMemberEntity> members;
  final TextEditingController amountController;

  @override
  State<ExpenseSplitWidget> createState() => _ExpenseSplitWidgetState();
}

class _ExpenseSplitWidgetState extends State<ExpenseSplitWidget> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final member in widget.members) {
      _controllers[member.userId] = TextEditingController();
    }
    widget.amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    widget.amountController.removeListener(_onAmountChanged);
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onAmountChanged() {
    if (widget.splitType == ExpenseSplitType.shares) {
      setState(() {});
    }
  }

  void _notifyChanges() {
    final splits = <Map<String, dynamic>>[];
    for (final member in widget.members) {
      final value = _controllers[member.userId]!.text;
      if (value.isNotEmpty) {
        final parsed = stringToMinorUnits(value);
        if (parsed > 0) {
          if (widget.splitType == ExpenseSplitType.shares) {
            splits.add({'userId': member.userId, 'shares': parsed});
          } else {
            splits.add({'userId': member.userId, 'amount': parsed});
          }
        }
      }
    }
    widget.onSplitsChanged(splits);
  }

  Map<String, int> _calculatePreviews() {
    final previews = <String, int>{};
    if (widget.splitType != ExpenseSplitType.shares) return previews;

    final totalAmount = stringToMinorUnits(widget.amountController.text);
    int totalShares = 0;
    final shareMap = <String, int>{};
    for (final member in widget.members) {
      final shares = int.tryParse(_controllers[member.userId]?.text ?? '') ?? 0;
      shareMap[member.userId] = shares;
      totalShares += shares;
    }

    if (totalShares == 0 || totalAmount == 0) return previews;

    int sum = 0;
    for (final member in widget.members) {
      final shares = shareMap[member.userId]!;
      final amount = (totalAmount * shares / totalShares).round();
      previews[member.userId] = amount;
      sum += amount;
    }

    final diff = totalAmount - sum;
    if (diff != 0) {
      for (final member in widget.members) {
        if ((shareMap[member.userId] ?? 0) > 0) {
          previews[member.userId] = previews[member.userId]! + diff;
          break;
        }
      }
    }
    return previews;
  }

  @override
  Widget build(BuildContext context) {
    final previews = _calculatePreviews();
    final isShares = widget.splitType == ExpenseSplitType.shares;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Split Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...widget.members.map((member) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(member.displayName),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _controllers[member.userId],
                        keyboardType: isShares
                            ? TextInputType.number
                            : const TextInputType.numberWithOptions(
                                decimal: true),
                        decoration: InputDecoration(
                          hintText: isShares ? 'Shares (e.g. 1)' : 'Amount',
                          isDense: true,
                        ),
                        onChanged: (_) {
                          _notifyChanges();
                          if (widget.splitType == ExpenseSplitType.shares) {
                            setState(() {});
                          }
                        },
                      ),
                      if (widget.splitType == ExpenseSplitType.shares &&
                          previews[member.userId] != null &&
                          previews[member.userId]! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '~ ${formatMinorUnits(previews[member.userId]!)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
