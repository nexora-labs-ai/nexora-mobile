import 'package:flutter/material.dart';
import '../../../../../core/utils/currency_utils.dart';

import '../../../groups/domain/entities/group_entity.dart';

class ExpenseSplitWidget extends StatefulWidget {
  const ExpenseSplitWidget({
    required this.splitType,
    required this.onSplitsChanged,
    required this.members,
    super.key,
  });

  final String splitType;
  final ValueChanged<List<Map<String, dynamic>>> onSplitsChanged;
  final List<GroupMemberEntity> members;

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
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final splits = <Map<String, dynamic>>[];
    for (final member in widget.members) {
      final text = _controllers[member.userId]?.text ?? '';
      if (text.isNotEmpty) {
        if (widget.splitType == 'SHARES') {
          final shares = int.tryParse(text);
          if (shares != null && shares > 0) {
            splits.add({'userId': member.userId, 'shares': shares});
          }
        } else {
          final amount = stringToMinorUnits(text);
          if (amount > 0) {
            splits.add({'userId': member.userId, 'amount': amount});
          }
        }
      }
    }
    widget.onSplitsChanged(splits);
  }

  @override
  Widget build(BuildContext context) {
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
                  child: TextField(
                    controller: _controllers[member.userId],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: widget.splitType == 'SHARES'
                          ? 'Shares (e.g. 1)'
                          : 'Amount',
                      isDense: true,
                    ),
                    onChanged: (_) => _notifyChanges(),
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
