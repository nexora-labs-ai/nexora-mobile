import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/itinerary_model.dart';
import '../blocs/itinerary_cubit.dart';

class EditItineraryItemBottomSheet extends StatefulWidget {
  final String groupId;
  final String itineraryId;
  final ItineraryItemModel? existingItem;
  final DateTime defaultDate;

  const EditItineraryItemBottomSheet({
    required this.groupId,
    required this.itineraryId,
    this.existingItem,
    required this.defaultDate,
    super.key,
  });

  @override
  State<EditItineraryItemBottomSheet> createState() =>
      _EditItineraryItemBottomSheetState();
}

class _EditItineraryItemBottomSheetState
    extends State<EditItineraryItemBottomSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _costCtrl;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _titleCtrl = TextEditingController(text: item?.title ?? '');
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _locCtrl = TextEditingController(text: item?.location ?? '');
    _costCtrl =
        TextEditingController(text: item?.estimatedCost?.toString() ?? '');

    _startTime = item != null
        ? TimeOfDay.fromDateTime(item.startTime)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = item != null
        ? TimeOfDay.fromDateTime(item.endTime)
        : const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    final start = DateTime.utc(
      widget.defaultDate.year,
      widget.defaultDate.month,
      widget.defaultDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final end = DateTime.utc(
      widget.defaultDate.year,
      widget.defaultDate.month,
      widget.defaultDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      'title': title,
      'description': _descCtrl.text.trim(),
      'location': _locCtrl.text.trim(),
      'startTime': start.toIso8601String(),
      'endTime': end.toIso8601String(),
      'estimatedCost': double.tryParse(_costCtrl.text.trim()),
    };

    String? error;
    if (widget.existingItem != null) {
      error = await context.read<ItineraryCubit>().updateItem(
          widget.itineraryId, widget.existingItem!.id, data, widget.groupId);
    } else {
      error = await context
          .read<ItineraryCubit>()
          .createItem(widget.itineraryId, data, widget.groupId);
    }

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Validation Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.pop(context);
    }
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existingItem != null ? 'Edit Activity' : 'Add Activity',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locCtrl,
              decoration: const InputDecoration(
                  labelText: 'Location', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Estimated Cost (\$)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: _startTime);
                      if (t != null) setState(() => _startTime = t);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder()),
                      child: Text(_startTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: _endTime);
                      if (t != null) setState(() => _endTime = t);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'End Time', border: OutlineInputBorder()),
                      child: Text(_endTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Save'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
