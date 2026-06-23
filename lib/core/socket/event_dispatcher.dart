import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../logger/app_logger.dart';
import 'socket_service.dart';

/// Maps raw socket events to typed, named stream channels.
///
/// Features subscribe to specific channels:
/// ```dart
/// eventDispatcher.on<ChatMessageEvent>('chat:message')
///   .listen((event) { ... });
/// ```
@singleton
class EventDispatcher {
  EventDispatcher(this._socketService);

  final SocketService _socketService;

  final _channels = <String, Subject<dynamic>>{};

  /// Returns a broadcast stream for [event].
  /// Lazily registers the socket handler on first subscription.
  Stream<T> on<T>(String event) {
    if (!_channels.containsKey(event)) {
      // ignore: close_sinks
      final subject = PublishSubject<dynamic>();
      _channels[event] = subject;

      _socketService.on(event, (data) {
        AppLogger.trace('EventDispatcher received: $event');
        subject.add(data);
      });
    }
    return _channels[event]!.stream.cast<T>();
  }

  /// Emits [event] with optional [data].
  void emit(String event, [dynamic data]) {
    _socketService.emit(event, data);
  }

  /// Unregisters the listener and closes the stream for [event].
  void unsubscribe(String event) {
    _channels[event]?.close();
    _channels.remove(event);
    _socketService.off(event);
  }

  void dispose() {
    for (final subject in _channels.values) {
      subject.close();
    }
    _channels.clear();
  }
}
