// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../groups/domain/entities/group_entity.dart';

class SplitFormWidget extends StatefulWidget {
  const SplitFormWidget({
    required this.amount,
    required this.members,
    required this.onSplitsChanged,
    super.key,
  });

  final double amount;
  final List<GroupMemberEntity> members;
  final void Function(String splitType, List<Map<String, dynamic>> splits)
      onSplitsChanged;

  @override
  State<SplitFormWidget> createState() => _SplitFormWidgetState();
}

class _SplitFormWidgetState extends State<SplitFormWidget> {
  String _splitType = 'SHARES';
  final Map<String, bool> _selectedMembers = {};
  final Map<String, TextEditingController> _amountControllers = {};

  @override
  void initState() {
    super.initState();
    for (final m in widget.members) {
      _selectedMembers[m.userId] = true;
      _amountControllers[m.userId] = TextEditingController();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChanges();
    });
  }

  @override
  void dispose() {
    for (final c in _amountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final splits = <Map<String, dynamic>>[];
    if (_splitType == 'SHARES') {
      for (final m in widget.members) {
        if (_selectedMembers[m.userId] == true) {
          splits.add({'userId': m.userId, 'shares': 1});
        }
      }
    } else {
      for (final m in widget.members) {
        final text = _amountControllers[m.userId]?.text ?? '';
        final val = double.tryParse(text.replaceAll(',', ''));
        if (val != null && val > 0) {
          splits.add({'userId': m.userId, 'amount': val});
        }
      }
    }
    widget.onSplitsChanged(_splitType, splits);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Split Type', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Equally'),
                value: 'SHARES',
                groupValue: _splitType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _splitType = val);
                    _notifyChanges();
                  }
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Exact Amounts'),
                value: 'EXACT',
                groupValue: _splitType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _splitType = val);
                    _notifyChanges();
                  }
                },
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Participants', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...widget.members.map((GroupMemberEntity m) {
          if (_splitType == 'SHARES') {
            return CheckboxListTile(
              value: _selectedMembers[m.userId] ?? false,
              title: Text(m.displayName),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (val) {
                setState(() {
                  _selectedMembers[m.userId] = val ?? false;
                });
                _notifyChanges();
              },
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(m.displayName,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountControllers[m.userId],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (_) => _notifyChanges(),
                    ),
                  ),
                ],
              ),
            );
          }
        }),
        if (_splitType == 'EXACT') ...[
          const SizedBox(height: 16),
          Builder(builder: (context) {
            double totalEntered = 0;
            for (final m in widget.members) {
              final text = _amountControllers[m.userId]?.text ?? '';
              final val = double.tryParse(text.replaceAll(',', ''));
              if (val != null) totalEntered += val;
            }
            final diff = widget.amount - totalEntered;
            final isMatch = (diff.abs() < 0.01);
            return Text(
              isMatch
                  ? 'Total matches expense amount'
                  : 'Difference: ${diff.toStringAsFixed(2)}',
              style: TextStyle(
                color: isMatch ? Colors.green : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ]
      ],
    );
  }
}
