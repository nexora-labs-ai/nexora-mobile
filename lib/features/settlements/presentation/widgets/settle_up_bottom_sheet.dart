import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexora_mobile/core/theme/app_colors.dart';
import 'package:nexora_mobile/core/theme/app_text_styles.dart';
import 'package:nexora_mobile/shared/widgets/app_button.dart';
import 'package:nexora_mobile/shared/widgets/app_text_field.dart';

import '../bloc/settlement_bloc.dart';

class SettleUpBottomSheet extends StatefulWidget {
  final String groupId;
  final String toUserId;
  final int amount;
  final SettlementBloc bloc;

  const SettleUpBottomSheet({
    super.key,
    required this.groupId,
    required this.toUserId,
    required this.amount,
    required this.bloc,
  });

  @override
  State<SettleUpBottomSheet> createState() => _SettleUpBottomSheetState();
}

class _SettleUpBottomSheetState extends State<SettleUpBottomSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  File? _evidenceFile;
  final _imagePicker = ImagePicker();

  Future<void> _pickEvidence() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _evidenceFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final amtDouble = widget.amount / 100;
    _amountController.text = amtDouble == amtDouble.toInt()
        ? amtDouble.toInt().toString()
        : amtDouble.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Settle Up',
                  style: AppTextStyles.headlineSmall
                      .copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _amountController,
            label: 'Amount to Pay (USD)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _noteController,
            label: 'Note (Optional)',
            hint: 'e.g. For dinner yesterday',
          ),
          const SizedBox(height: 16),
          if (_evidenceFile != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _evidenceFile!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => setState(() => _evidenceFile = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: _pickEvidence,
              icon: const Icon(Icons.upload_file),
              label: const Text('Attach Evidence (Optional)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Record Payment',
            onPressed: () {
              final amountText = _amountController.text.trim();
              if (amountText.isEmpty) return;

              final amountDouble = double.tryParse(amountText);
              if (amountDouble == null || amountDouble <= 0) return;

              final amountInCents = (amountDouble * 100).round();

              widget.bloc.add(RequestSettlement(
                groupId: widget.groupId,
                toUserId: widget.toUserId,
                amount: amountInCents,
                currency: 'USD',
                note: _noteController.text.trim(),
                evidenceFile: _evidenceFile,
              ));

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
