import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/dio_error_mapper.dart';
import '../../../../core/services/global_cache_service.dart';
import '../../data/models/itinerary_model.dart';
import '../../data/repositories/itinerary_repository.dart';
import 'itinerary_state.dart';

@injectable
class ItineraryCubit extends Cubit<ItineraryState> {
  final ItineraryRepository _repository;
  final GlobalCacheService _cacheService;

  ItineraryCubit(this._repository, this._cacheService)
      : super(ItineraryInitial());

  Future<void> loadItineraries(String groupId) async {
    if (_cacheService.itineraryCache.containsKey(groupId)) {
      emit(_cacheService.itineraryCache[groupId]!);
    } else {
      emit(ItineraryLoading());
    }

    try {
      final itineraries = await _repository.getGroupItineraries(groupId);
      final newState = ItineraryLoaded(itineraries);
      _cacheService.itineraryCache[groupId] = newState;
      emit(newState);
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
    final current = state is ItineraryLoaded
        ? (state as ItineraryLoaded).itineraries
        : <ItineraryModel>[];
    emit(ItineraryGenerating(current));
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

  Future<void> createManualItinerary({
    required String groupId,
    required String title,
    String? destination,
    String? startDate,
    String? endDate,
    String? description,
  }) async {
    emit(ItineraryLoading());
    try {
      await _repository.createManualItinerary(
        groupId: groupId,
        title: title,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        description: description,
      );
      // Reload after successful creation
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
      final msg = e is DioException
          ? DioErrorMapper.toFailure(e).message
          : e.toString().replaceAll('Exception: ', '');
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
      final msg = e is DioException
          ? DioErrorMapper.toFailure(e).message
          : e.toString().replaceAll('Exception: ', '');
      emit(ItineraryError(msg));
      return msg;
    }
  }

  Future<void> aiEditItem(
      String itineraryId, String itemId, String prompt, String groupId) async {
    final current = state is ItineraryLoaded
        ? (state as ItineraryLoaded).itineraries
        : <ItineraryModel>[];
    emit(ItineraryGenerating(current));
    try {
      await _repository.aiEditItineraryItem(itineraryId, itemId, prompt);
      await loadItineraries(groupId);
    } catch (e) {
      final msg = e is DioException
          ? DioErrorMapper.toFailure(e).message
          : e.toString();
      emit(ItineraryError(msg));
    }
  }

  Future<void> aiEditEntireItinerary(
      String itineraryId, String prompt, String groupId) async {
    final current = state is ItineraryLoaded
        ? (state as ItineraryLoaded).itineraries
        : <ItineraryModel>[];
    emit(ItineraryGenerating(current));
    try {
      await _repository.aiEditEntireItinerary(itineraryId, prompt);
      await loadItineraries(groupId);
    } catch (e) {
      final msg = e is DioException
          ? DioErrorMapper.toFailure(e).message
          : e.toString();
      emit(ItineraryError(msg));
    }
  }
}
