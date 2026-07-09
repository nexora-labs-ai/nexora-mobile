import '../../data/models/itinerary_model.dart';

abstract class ItineraryState {}

class ItineraryInitial extends ItineraryState {}

class ItineraryLoading extends ItineraryState {}

class ItineraryLoaded extends ItineraryState {
  final List<ItineraryModel> itineraries;
  ItineraryLoaded(this.itineraries);
}

class ItineraryGenerating extends ItineraryState {}

class ItineraryError extends ItineraryState {
  final String message;
  ItineraryError(this.message);
}
