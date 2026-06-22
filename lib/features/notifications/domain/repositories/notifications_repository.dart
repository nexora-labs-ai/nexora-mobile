import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, List<dynamic>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> markAllAsRead();
}
