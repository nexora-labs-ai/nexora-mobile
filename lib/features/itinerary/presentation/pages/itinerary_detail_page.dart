import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/itinerary_model.dart';
import '../blocs/itinerary_cubit.dart';
import '../blocs/itinerary_state.dart';
import 'ai_edit_bottom_sheet.dart';
import 'edit_itinerary_item_bottom_sheet.dart';

class ItineraryDetailPage extends StatefulWidget {
  final String groupId;
  final ItineraryModel itinerary;

  const ItineraryDetailPage({
    required this.groupId,
    required this.itinerary,
    super.key,
  });

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage> {
  late ItineraryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ItineraryCubit>();
  }

  void _openManualEdit(ItineraryItemModel? item, DateTime defaultDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: EditItineraryItemBottomSheet(
          groupId: widget.groupId,
          itineraryId: widget.itinerary.id,
          existingItem: item,
          defaultDate: defaultDate,
        ),
      ),
    );
  }

  void _openAiEdit({String? itemId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: _cubit,
        child: AiEditBottomSheet(
          groupId: widget.groupId,
          itineraryId: widget.itinerary.id,
          itemId: itemId,
        ),
      ),
    );
  }

  void _deleteItem(ItineraryItemModel item) {
    _cubit.deleteItem(widget.itinerary.id, item.id, widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ItineraryCubit, ItineraryState>(
        builder: (context, state) {
          ItineraryModel currentItinerary = widget.itinerary;
          if (state is ItineraryLoaded) {
            final updated = state.itineraries
                .where((i) => i.id == widget.itinerary.id)
                .firstOrNull;
            if (updated != null) currentItinerary = updated;
          }

          // Group by Day
          Map<DateTime, List<ItineraryItemModel>> groupedItems = {};
          for (var item in currentItinerary.items) {
            final date = DateTime(
                item.startTime.year, item.startTime.month, item.startTime.day);
            groupedItems.putIfAbsent(date, () => []).add(item);
          }
          final days = groupedItems.keys.toList()..sort();

          // Fallback date for new items
          final defaultDate = days.isNotEmpty ? days.first : DateTime.now();

          return DefaultTabController(
            length: days.isEmpty ? 1 : days.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text(currentItinerary.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    tooltip: 'AI Modify Plan',
                    onPressed: () => _openAiEdit(), // whole plan
                  ),
                ],
                bottom: days.isNotEmpty
                    ? TabBar(
                        isScrollable: true,
                        tabs: List.generate(days.length, (index) {
                          return Tab(
                              text:
                                  'Day ${index + 1}\n${DateFormat('MMM d').format(days[index])}');
                        }),
                      )
                    : null,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _openManualEdit(null, defaultDate),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
              body: Stack(
                children: [
                  if (days.isEmpty)
                    const Center(child: Text('No activities yet.'))
                  else
                    TabBarView(
                      children: days.map((day) {
                        final items = groupedItems[day]!
                          ..sort((a, b) => a.startTime.compareTo(b.startTime));
                        return ListView.builder(
                          padding:
                              const EdgeInsets.all(16).copyWith(bottom: 80),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final startStr =
                                DateFormat('HH:mm').format(item.startTime);
                            final endStr =
                                DateFormat('HH:mm').format(item.endTime);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Text(startStr,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.primary)),
                                        const SizedBox(height: 4),
                                        const Text('to',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(endStr,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.primary)),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                          if (item.location != null &&
                                              item.location!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    size: 14,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                    child: Text(item.location!,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.grey))),
                                              ],
                                            ),
                                          ],
                                          if (item.description != null &&
                                              item.description!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(item.description!,
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ],
                                          if (item.travelTime != null &&
                                              item.travelTime! > 0) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.directions_car,
                                                    size: 14,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                    'Travel time: ${item.travelTime} min',
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                          if (item.estimatedCost != null) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: AppColors
                                                      .surfaceContainerLow,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Text(
                                                  '\$${item.estimatedCost}',
                                                  style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _openManualEdit(item, day);
                                        }
                                        if (value == 'ai_edit') {
                                          _openAiEdit(itemId: item.id);
                                        }
                                        if (value == 'delete') {
                                          _deleteItem(item);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                            value: 'ai_edit',
                                            child: Row(children: [
                                              Icon(Icons.auto_awesome,
                                                  color: AppColors.primary,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text('AI Edit')
                                            ])),
                                        const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text('Manual Edit')
                                            ])),
                                        const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              SizedBox(width: 8),
                                              Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red))
                                            ])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  if (state is ItineraryLoading || state is ItineraryGenerating)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Applying Magic...',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
