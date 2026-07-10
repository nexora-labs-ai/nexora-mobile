import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../blocs/itinerary_cubit.dart';

class AiEditBottomSheet extends StatefulWidget {
  final String groupId;
  final String itineraryId;
  final String? itemId; // If null, applies to whole plan

  const AiEditBottomSheet({
    required this.groupId,
    required this.itineraryId,
    this.itemId,
    super.key,
  });

  @override
  State<AiEditBottomSheet> createState() => _AiEditBottomSheetState();
}

class _AiEditBottomSheetState extends State<AiEditBottomSheet> {
  final _promptCtrl = TextEditingController();

  void _submit() {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) return;

    if (widget.itemId != null) {
      context.read<ItineraryCubit>().aiEditItem(
          widget.itineraryId, widget.itemId!, prompt, widget.groupId);
    } else {
      context
          .read<ItineraryCubit>()
          .aiEditEntireItinerary(widget.itineraryId, prompt, widget.groupId);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                widget.itemId != null ? 'AI Item Edit' : 'AI Plan Modification',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.itemId != null
                ? 'Tell AI what you want to change for this activity.'
                : 'Tell AI how to adjust the entire itinerary (e.g. shift times, make it more relaxing).',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _promptCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Type your prompt here...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Apply Magic'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
