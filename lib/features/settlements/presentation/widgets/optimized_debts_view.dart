import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/currency_utils.dart';
import '../bloc/settlement_bloc.dart';

class OptimizedDebtsView extends StatelessWidget {
  const OptimizedDebtsView({
    required this.state,
    required this.userNames,
    required this.currentUserId,
    required this.groupId,
    super.key,
  });

  final SettlementLoaded state;
  final Map<String, String> userNames;
  final String currentUserId;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final debts = state.optimizedSettlements;
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 80, color: Colors.green.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('All Settled Up!',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('You are totally debt-free in this group.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final fromName = userNames[debt.fromUserId] ?? 'Unknown';
        final toName = userNames[debt.toUserId] ?? 'Unknown';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fromName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const Text('Owes',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: Colors.grey, size: 20),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(toName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const Text('Receives',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            backgroundColor:
                                Colors.purple.withValues(alpha: 0.1),
                            child:
                                const Icon(Icons.person, color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('\$${formatMinorUnits(debt.amount)}',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: -0.5)),
                  ),
                ),
                if (debt.fromUserId == currentUserId) ...[
                  const Divider(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () {
                        _showSettleUpDialog(
                          context,
                          debt.toUserId,
                          debt.amount,
                        );
                      },
                      child: const Text('Settle Up',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettleUpDialog(BuildContext context, String toUserId, int amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return _SettleUpBottomSheet(
          groupId: groupId,
          toUserId: toUserId,
          amount: amount,
          bloc: context.read<SettlementBloc>(),
        );
      },
    );
  }
}

class _SettleUpBottomSheet extends StatefulWidget {
  final String groupId;
  final String toUserId;
  final int amount;
  final SettlementBloc bloc;

  const _SettleUpBottomSheet({
    required this.groupId,
    required this.toUserId,
    required this.amount,
    required this.bloc,
  });

  @override
  State<_SettleUpBottomSheet> createState() => _SettleUpBottomSheetState();
}

class _SettleUpBottomSheetState extends State<_SettleUpBottomSheet> {
  final TextEditingController _noteController = TextEditingController();
  File? _evidenceFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _evidenceFile = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Confirm Settle Up',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (_evidenceFile != null) ...[
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _evidenceFile!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  onPressed: () => setState(() => _evidenceFile = null),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ] else
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Upload Evidence (Optional)'),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              widget.bloc.add(RequestSettlement(
                groupId: widget.groupId,
                toUserId: widget.toUserId,
                amount: widget.amount,
                currency: 'USD',
                note: _noteController.text.isNotEmpty
                    ? _noteController.text
                    : null,
                evidenceFile: _evidenceFile,
              ));
              Navigator.pop(context);
            },
            child: const Text(
              'Confirm Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
