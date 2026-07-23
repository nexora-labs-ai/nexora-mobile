import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/itinerary_repository.dart';
import 'itinerary_state.dart';

@injectable
class ItineraryCubit extends Cubit<ItineraryState> {
  final ItineraryRepository _repository;

  ItineraryCubit(this._repository) : super(ItineraryInitial());

  Future<void> loadItineraries(String groupId) async {
    emit(ItineraryLoading());
    try {
      final itineraries = await _repository.getGroupItineraries(groupId);
      emit(ItineraryLoaded(itineraries));
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }

  Future<void> generateAiItinerary({
    required String groupId,
    required String destination,
    double? budget,
    List<String>? interests,
  }) async {
    emit(ItineraryGenerating());
    try {
      await _repository.generateAiItinerary(
        groupId: groupId,
        destination: destination,
        budget: budget,
        interests: interests,
      );
      // Reload after successful generation
      await loadItineraries(groupId);
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }

  Future<void> updateItemTime(String itineraryId, String itemId,
      DateTime newStart, DateTime newEnd, String groupId) async {
    try {
      await _repository.updateItineraryItem(itineraryId, itemId, {
        'startTime': newStart.toIso8601String(),
        'endTime': newEnd.toIso8601String(),
      });
      // Reload to get updated and shifted items
      await loadItineraries(groupId);
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }

  Future<void> deleteItem(
      String itineraryId, String itemId, String groupId) async {
    try {
      await _repository.deleteItineraryItem(itineraryId, itemId);
      // Reload to get updated items
      await loadItineraries(groupId);
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }

  Future<String?> createItem(
      String itineraryId, Map<String, dynamic> itemDto, String groupId) async {
    try {
      await _repository.createItineraryItem(itineraryId, itemDto);
      await loadItineraries(groupId);
      return null;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(ItineraryError(msg));
      return msg;
    }
  }

  Future<String?> updateItem(String itineraryId, String itemId,
      Map<String, dynamic> data, String groupId) async {
    try {
      await _repository.updateItineraryItem(itineraryId, itemId, data);
      await loadItineraries(groupId);
      return null;
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(ItineraryError(msg));
      return msg;
    }
  }

  Future<void> aiEditItem(
      String itineraryId, String itemId, String prompt, String groupId) async {
    emit(ItineraryGenerating());
    try {
      await _repository.aiEditItineraryItem(itineraryId, itemId, prompt);
      await loadItineraries(groupId);
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }

  Future<void> aiEditEntireItinerary(
      String itineraryId, String prompt, String groupId) async {
    emit(ItineraryGenerating());
    try {
      await _repository.aiEditEntireItinerary(itineraryId, prompt);
      await loadItineraries(groupId);
    } catch (e) {
      emit(ItineraryError(e.toString()));
    }
  }
}
