import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../blocs/itinerary_cubit.dart';
import '../blocs/itinerary_state.dart';
import 'create_manual_itinerary_bottom_sheet.dart';
import 'generate_itinerary_bottom_sheet.dart';

class ItineraryPage extends StatelessWidget {
  final String groupId;
  final bool isTab;

  const ItineraryPage({required this.groupId, this.isTab = false, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ItineraryCubit>()..loadItineraries(groupId),
      child: Scaffold(
        appBar: isTab
            ? null
            : AppBar(
                title: const Text('Itineraries'),
              ),
        body: BlocBuilder<ItineraryCubit, ItineraryState>(
          builder: (context, state) {
            if (state is ItineraryLoading || state is ItineraryGenerating) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ItineraryError) {
              return Center(
                  child: Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red)));
            } else if (state is ItineraryLoaded) {
              if (state.itineraries.isEmpty) {
                return const Center(
                  child: Text('No itineraries yet. Generate one with AI!'),
                );
              }
              return ListView.builder(
                itemCount: state.itineraries.length,
                itemBuilder: (context, index) {
                  final itinerary = state.itineraries[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(itinerary.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${itinerary.destination} • ${itinerary.items.length} items'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.push(
                            '/groups/$groupId/itinerary/${itinerary.id}',
                            extra: itinerary);
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.auto_awesome, color: AppColors.primary),
                        title: const Text('Generate with AI'),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => BlocProvider.value(
                              value: context.read<ItineraryCubit>(),
                              child: GenerateItineraryBottomSheet(groupId: groupId),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit_calendar),
                        title: const Text('Create Empty Itinerary'),
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => BlocProvider.value(
                              value: context.read<ItineraryCubit>(),
                              child: CreateManualItineraryBottomSheet(groupId: groupId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
