import 'package:injectable/injectable.dart';

import '../../../../core/base/base_cubit.dart';
import '../../../../core/errors/failure.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

@injectable
class NotificationsCubit extends BaseCubit<NotificationsState> {
  NotificationsCubit(
    NotificationsRepository notificationsRepository,
    GroupRepository groupRepository,
  )   : _notificationsRepository = notificationsRepository,
        _groupRepository = groupRepository,
        super(const NotificationsInitial());

  final NotificationsRepository _notificationsRepository;
  final GroupRepository _groupRepository;

  Future<void> loadNotifications() async {
    safeEmit(const NotificationsLoading());

    final result = await _notificationsRepository.getNotifications();

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(NotificationsFailure(message: failure.message));
      },
      (notifications) => safeEmit(NotificationsLoaded(notifications: notifications)),
    );
  }

  Future<void> markAsRead(String id) async {
    await _notificationsRepository.markAsRead(id);
    loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _notificationsRepository.markAllAsRead();
    loadNotifications();
  }

  Future<void> acceptInvitation(String notificationId, String token) async {
    safeEmit(const NotificationsLoading());
    final result = await _groupRepository.acceptInvitation(token);
    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(NotificationsFailure(message: failure.message));
        loadNotifications();
      },
      (_) async {
        await _notificationsRepository.markAsRead(notificationId);
        loadNotifications();
      },
    );
  }

  Future<void> rejectInvitation(String notificationId, String token) async {
    safeEmit(const NotificationsLoading());
    final result = await _groupRepository.rejectInvitation(token);
    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(NotificationsFailure(message: failure.message));
        loadNotifications();
      },
      (_) async {
        await _notificationsRepository.markAsRead(notificationId);
        loadNotifications();
      },
    );
  }
}
