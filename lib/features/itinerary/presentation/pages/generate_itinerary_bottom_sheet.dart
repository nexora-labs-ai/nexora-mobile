import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/itinerary_cubit.dart';

class GenerateItineraryBottomSheet extends StatefulWidget {
  final String groupId;

  const GenerateItineraryBottomSheet({required this.groupId, super.key});

  @override
  State<GenerateItineraryBottomSheet> createState() => _GenerateItineraryBottomSheetState();
}

class _GenerateItineraryBottomSheetState extends State<GenerateItineraryBottomSheet> {
  final _destinationCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '3');
  final _budgetCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _durationCtrl.dispose();
    _budgetCtrl.dispose();
    _interestsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final destination = _destinationCtrl.text.trim();
    final duration = int.tryParse(_durationCtrl.text) ?? 3;
    final budget = double.tryParse(_budgetCtrl.text);
    final interests = _interestsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Destination is required')));
      return;
    }

    context.read<ItineraryCubit>().generateAiItinerary(
          groupId: widget.groupId,
          destination: destination,
          duration: duration,
          budget: budget,
          interests: interests,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Plan with AI', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _destinationCtrl,
            decoration: const InputDecoration(labelText: 'Destination (e.g. Tokyo, Paris)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _durationCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (Days)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _budgetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Estimated Budget (Optional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _interestsCtrl,
            decoration: const InputDecoration(labelText: 'Interests (comma separated)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Itinerary'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
