import 'package:logger/logger.dart';

import '../environment/app_env.dart';

/// Thin wrapper around [Logger] that respects environment settings.
///
/// Usage:
/// ```dart
/// AppLogger.info('User logged in');
/// AppLogger.error('Token refresh failed', error: e, stackTrace: st);
/// ```
abstract final class AppLogger {
  static Logger? _logger;

  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
      output: AppEnv.instance.enableLogging ? ConsoleOutput() : null,
      level: AppEnv.instance.enableLogging ? Level.trace : Level.off,
    );
  }

  static Logger get _activeLogger => _logger ??= Logger(level: Level.off);

  static void trace(String message) => _activeLogger.t(message);
  static void debug(String message) => _activeLogger.d(message);
  static void info(String message) => _activeLogger.i(message);
  static void warning(String message) => _activeLogger.w(message);
  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _activeLogger.e(message, error: error, stackTrace: stackTrace);
  static void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _activeLogger.f(message, error: error, stackTrace: stackTrace);
}
