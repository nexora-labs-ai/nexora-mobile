import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/failure.dart';
import '../logger/app_logger.dart';

/// Base [Cubit] that adds structured logging and safe emit helpers.
///
/// All feature cubits extend this class.
abstract class BaseCubit<State> extends Cubit<State> {
  BaseCubit(super.initialState);

  /// Emits a new state only when the cubit is still open.
  void safeEmit(State state) {
    if (isClosed) return;
    emit(state);
  }

  /// Logs a [Failure] at warning level with cubit context.
  void logFailure(Failure failure) {
    AppLogger.warning('[${runtimeType}] Failure: ${failure.message} (code: ${failure.code})');
  }

  @override
  void onChange(Change<State> change) {
    super.onChange(change);
    AppLogger.trace('[${runtimeType}] State: ${change.nextState.runtimeType}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    AppLogger.error('[${runtimeType}] Error', error: error, stackTrace: stackTrace);
    super.onError(error, stackTrace);
  }
}
