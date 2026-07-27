import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

          // Generate days based on itinerary startDate and endDate
          final start = currentItinerary.startDate; // Keep as UTC
          final end = currentItinerary.endDate; // Keep as UTC
          final normalizedStart =
              DateTime.utc(start.year, start.month, start.day);
          final normalizedEnd = DateTime.utc(end.year, end.month, end.day);

          List<DateTime> days = [];
          for (var i = 0;
              i <= normalizedEnd.difference(normalizedStart).inDays;
              i++) {
            days.add(normalizedStart.add(Duration(days: i)));
          }
          if (days.isEmpty) days.add(normalizedStart);

          // Group by Day
          Map<DateTime, List<ItineraryItemModel>> groupedItems = {
            for (var d in days) d: []
          };
          for (var item in currentItinerary.items) {
            final time = item.startTime; // It is UTC
            final date = DateTime.utc(time.year, time.month, time.day);
            groupedItems.putIfAbsent(date, () => []).add(item);
            if (!days.contains(date)) days.add(date);
          }
          days.sort();

          // Fallback date for new items
          final defaultDate = days.isNotEmpty ? days.first : DateTime.now();

          return DefaultTabController(
            length: days.isEmpty ? 1 : days.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  currentItinerary.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
              floatingActionButton: Builder(
                builder: (context) {
                  return FloatingActionButton(
                    onPressed: () {
                      final tabController =
                          DefaultTabController.maybeOf(context);
                      final index = tabController?.index ?? 0;
                      final selectedDate =
                          (days.isNotEmpty && index < days.length)
                              ? days[index]
                              : defaultDate;
                      _openManualEdit(null, selectedDate);
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  );
                },
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

                        if (items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'No activities yet for Day ${days.indexOf(day) + 1}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding:
                              const EdgeInsets.all(16).copyWith(bottom: 80),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final startStr = DateFormat('hh:mm a')
                                .format(item.startTime); // UTC
                            final endStr = DateFormat('hh:mm a')
                                .format(item.endTime); // UTC

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    width: 56,
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        if (index < items.length - 1)
                                          Positioned(
                                            top: 24,
                                            bottom: 0,
                                            child: Container(
                                              width: 2,
                                              // ignore: deprecated_member_use
                                              color: Colors.grey.withAlpha(
                                                  76), // 0.3 * 255 = 76.5
                                            ),
                                          ),
                                        Positioned(
                                          top: 16,
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE8F5E9),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(Icons.circle,
                                                  size: 12,
                                                  color: Colors.green),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16, bottom: 24, right: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            '$startStr - $endStr',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.green),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: (item.googleMapsUrl !=
                                                              null &&
                                                          item.googleMapsUrl!
                                                              .isNotEmpty)
                                                      ? () async {
                                                          try {
                                                            await launchUrlString(
                                                                item
                                                                    .googleMapsUrl!,
                                                                mode: LaunchMode
                                                                    .externalApplication);
                                                          } catch (_) {}
                                                        }
                                                      : null,
                                                  child: Text(item.title,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            item.googleMapsUrl !=
                                                                    null
                                                                ? Colors.blue
                                                                : Colors
                                                                    .black87,
                                                        decoration:
                                                            item.googleMapsUrl !=
                                                                    null
                                                                ? TextDecoration
                                                                    .underline
                                                                : null,
                                                        decorationColor:
                                                            Colors.blue,
                                                      )),
                                                ),
                                              ),
                                              PopupMenuButton<String>(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(
                                                    Icons.more_vert,
                                                    color: Colors.grey),
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _openManualEdit(item, day);
                                                  }
                                                  if (value == 'ai_edit') {
                                                    _openAiEdit(
                                                        itemId: item.id);
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
                                                            color: AppColors
                                                                .primary,
                                                            size: 20),
                                                        SizedBox(width: 8),
                                                        Text('AI Edit')
                                                      ])),
                                                  const PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(children: [
                                                        Icon(Icons.edit,
                                                            size: 20),
                                                        SizedBox(width: 8),
                                                        Text('Manual Edit')
                                                      ])),
                                                  const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(children: [
                                                        Icon(Icons.delete,
                                                            color: Colors.red,
                                                            size: 20),
                                                        SizedBox(width: 8),
                                                        Text('Delete',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red))
                                                      ])),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (item.location != null &&
                                              item.location!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(item.location!,
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 13)),
                                          ],
                                          const SizedBox(height: 12),
                                          if (item.imageUrl != null &&
                                              item.imageUrl!.isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                item.imageUrl!,
                                                height: 140,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    const SizedBox.shrink(),
                                              ),
                                            ),
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
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors
                                                      .surfaceContainerLow,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                    '${item.estimatedCost}',
                                                    style: const TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
