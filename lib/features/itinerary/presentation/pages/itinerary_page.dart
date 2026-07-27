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
            if (state is ItineraryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ItineraryError) {
              return Center(
                  child: Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red)));
            } else if (state is ItineraryLoaded || state is ItineraryGenerating) {
              final itineraries = state is ItineraryLoaded 
                  ? state.itineraries 
                  : (state as ItineraryGenerating).itineraries;
              final isGenerating = state is ItineraryGenerating;

              if (itineraries.isEmpty && !isGenerating) {
                return const Center(
                  child: Text('No itineraries yet. Generate one with AI!'),
                );
              }

              return ListView.builder(
                itemCount: itineraries.length + (isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isGenerating && index == 0) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        title: const Text('AI is generating itinerary...',
                            style: const TextStyle(fontStyle: FontStyle.italic)),
                        subtitle: const Text('Drafting magic...'),
                      ),
                    );
                  }

                  final itineraryIndex = isGenerating ? index - 1 : index;
                  final itinerary = itineraries[itineraryIndex];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
