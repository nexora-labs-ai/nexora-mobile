import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/itinerary_model.dart';

@injectable
class ItineraryRepository {
  final DioClient _dioClient;
  Dio get _dio => _dioClient.dio;

  ItineraryRepository(this._dioClient);

  Future<List<ItineraryModel>> getGroupItineraries(String groupId) async {
    final response = await _dio.get(
      ApiEndpoints.itinerary,
      queryParameters: {'groupId': groupId},
    );
    final data = response.data as List;
    return data.map((e) => ItineraryModel.fromJson(e)).toList();
  }

  Future<ItineraryModel> generateAiItinerary({
    required String groupId,
    required String destination,
    required int duration,
    double? budget,
    List<String>? interests,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.itineraryGenerate,
      queryParameters: {'groupId': groupId},
      data: {
        'destination': destination,
        'duration': duration,
        if (budget != null) 'budget': budget,
        if (interests != null && interests.isNotEmpty) 'interests': interests,
      },
    );
    return ItineraryModel.fromJson(response.data);
  }

  Future<void> createItineraryItem(String itineraryId, ItineraryItemModel item) async {
    await _dio.post(
      ApiEndpoints.itineraryItems(itineraryId),
      data: item.toJson(),
    );
  }

  Future<void> updateItineraryItem(String itineraryId, String itemId, Map<String, dynamic> data) async {
    await _dio.patch(
      ApiEndpoints.itineraryItemById(itineraryId, itemId),
      data: data,
    );
  }

  Future<void> deleteItineraryItem(String itineraryId, String itemId) async {
    await _dio.delete(
      ApiEndpoints.itineraryItemById(itineraryId, itemId),
    );
  }

  Future<void> aiEditItineraryItem(String itineraryId, String itemId, String prompt) async {
    await _dio.post(
      ApiEndpoints.itineraryItemAiEdit(itineraryId, itemId),
      data: {'prompt': prompt},
    );
  }

  Future<void> aiEditEntireItinerary(String itineraryId, String prompt) async {
    await _dio.post(
      ApiEndpoints.itineraryAiEdit(itineraryId),
      data: {'prompt': prompt},
    );
  }
}
