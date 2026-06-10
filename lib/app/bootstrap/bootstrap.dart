import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/environment/app_env.dart';
import '../../core/logger/app_logger.dart';
import '../bindings/injection_container.dart';
import '../app.dart';

/// Initializes all platform services before running [NexoraApp].
///
/// Order matters:
/// 1. Flutter engine binding
/// 2. Environment config
/// 3. Logger
/// 4. Hive (local DB)
/// 5. Firebase
/// 6. Dependency injection
/// 7. Run app
Future<void> bootstrap() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Lock orientation to portrait
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Transparent system status bar
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      );

      // Environment
      AppEnv.init(flavor: const String.fromEnvironment('FLAVOR', defaultValue: 'development'));

      // Logger
      AppLogger.init();

      // Hive local database
      await Hive.initFlutter();

      // Firebase
      await Firebase.initializeApp();

      // Dependency injection
      await configureDependencies();

      AppLogger.info('Bootstrap complete – starting NexoraApp');

      runApp(const NexoraApp());
    },
    (error, stack) {
      AppLogger.error('Uncaught zone error', error: error, stackTrace: stack);
    },
  );
}
