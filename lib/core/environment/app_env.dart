/// Application environment flavors.
enum Flavor { development, staging, production }

/// Provides environment-specific configuration resolved at startup.
///
/// Reads compile-time constants via [String.fromEnvironment] so no secrets
/// appear in code.  Always access via [AppEnv.instance].
abstract final class AppEnv {
  static late final AppEnv _instance;

  static AppEnv get instance => _instance;

  // ─── Public API ─────────────────────────────────────────────────────────────
  abstract final Flavor flavor;
  abstract final String baseUrl;
  abstract final String socketUrl;
  abstract final bool enableLogging;
  abstract final bool enableSslPinning;

  static void init({required String flavor}) {
    _instance = switch (flavor) {
      'production' => _ProductionEnv(),
      'staging' => _StagingEnv(),
      _ => _DevelopmentEnv(),
    };
  }
}

final class _DevelopmentEnv extends AppEnv {
  @override
  final Flavor flavor = Flavor.development;

  @override
  final String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  @override
  final String socketUrl = const String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  @override
  final bool enableLogging = true;

  @override
  final bool enableSslPinning = false;
}

final class _StagingEnv extends AppEnv {
  @override
  final Flavor flavor = Flavor.staging;

  @override
  final String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api-staging.nexora.app/api/v1',
  );

  @override
  final String socketUrl = const String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://api-staging.nexora.app',
  );

  @override
  final bool enableLogging = true;

  @override
  final bool enableSslPinning = true;
}

final class _ProductionEnv extends AppEnv {
  @override
  final Flavor flavor = Flavor.production;

  @override
  final String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.nexora.app/api/v1',
  );

  @override
  final String socketUrl = const String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'https://api.nexora.app',
  );

  @override
  final bool enableLogging = false;

  @override
  final bool enableSslPinning = true;
}
