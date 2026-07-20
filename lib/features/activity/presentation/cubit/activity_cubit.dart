import 'dart:async';
import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../../../core/base/base_cubit.dart';
import '../../domain/entities/activity_entity.dart';
import 'activity_state.dart';

@injectable
class ActivityCubit extends BaseCubit<ActivityState> {
  ActivityCubit() : super(const ActivityInitial());

  String? _currentGroupId;
  Timer? _mockWebSocketTimer;

  @override
  Future<void> close() {
    _mockWebSocketTimer?.cancel();
    return super.close();
  }

  void init() {
    fetchActivities();
    _startMockWebSocket();
  }

  void _startMockWebSocket() {
    _mockWebSocketTimer?.cancel();
    _mockWebSocketTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (state is ActivityLoaded) {
        final current = state as ActivityLoaded;
        final newActivity = _generateMockActivity();

        // Only add if it matches the current filter
        if (_currentGroupId == null || newActivity.groupId == _currentGroupId) {
          safeEmit(current.copyWith(
            activities: [newActivity, ...current.activities],
          ));
        }
      }
    });
  }

  Future<void> fetchActivities(
      {String? groupId, bool isRefresh = false}) async {
    if (!isRefresh) {
      safeEmit(const ActivityLoading());
    }

    _currentGroupId = groupId;

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final mockData = List.generate(10, (index) => _generateMockActivity());

      final filteredData = groupId == null
          ? mockData
          : mockData.where((a) => a.groupId == groupId).toList();

      safeEmit(ActivityLoaded(activities: filteredData, hasReachedMax: false));
    } catch (e) {
      safeEmit(ActivityFailure(message: e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state is! ActivityLoaded) return;
    final current = state as ActivityLoaded;
    if (current.hasReachedMax) return;

    try {
      await Future.delayed(const Duration(seconds: 1));
      final moreData = List.generate(5, (index) => _generateMockActivity());

      final filteredData = _currentGroupId == null
          ? moreData
          : moreData.where((a) => a.groupId == _currentGroupId).toList();

      safeEmit(current.copyWith(
        activities: [...current.activities, ...filteredData],
        hasReachedMax: false, // Set to true if empty in real scenario
      ));
    } catch (e) {
      // Handle error without clearing existing data
    }
  }

  ActivityEntity _generateMockActivity() {
    final random = Random();
    const types = ActivityType.values;
    final type = types[random.nextInt(types.length - 1)]; // Exclude unknown
    const groups = [
      {'id': '1', 'name': 'Da Nang Trip'},
      {'id': '2', 'name': 'Japan Trip'},
      {'id': '3', 'name': 'Company Retreat'}
    ];
    final group = groups[random.nextInt(groups.length)];
    final users = ['Alex', 'Jordan', 'Emma', 'Lucas', 'Sarah'];

    return ActivityEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString() +
          random.nextInt(1000).toString(),
      groupId: group['id']!,
      groupAvatar: null,
      groupName: group['name']!,
      userId: 'u${random.nextInt(100)}',
      userAvatar: null,
      userName: users[random.nextInt(users.length)],
      type: type,
      createdAt: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
      amount: random.nextDouble() > 0.5
          ? (random.nextInt(500) + 10).toDouble()
          : null,
      statusBadge: random.nextDouble() > 0.7 ? 'Warning' : null,
    );
  }
}
