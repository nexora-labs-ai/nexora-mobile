import 'package:injectable/injectable.dart';

import '../../features/groups/presentation/cubit/group_state.dart';
import '../../features/itinerary/presentation/blocs/itinerary_state.dart';
import '../../features/group_chat/presentation/bloc/group_chat_state.dart';

@lazySingleton
class GlobalCacheService {
  final Map<String, GroupDetailLoaded> groupDetailCache = {};
  final Map<String, ItineraryLoaded> itineraryCache = {};
  final Map<String, GroupChatLoaded> chatCache = {};
}
