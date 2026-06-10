import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../storage/secure_storage.dart';

/// GoRouter redirect guard – enforces authentication on protected routes.
///
/// Injected into [GoRouter.redirect]; keeps routing logic in one place
/// so individual pages have no knowledge of auth state.
abstract final class AuthGuard {
  static final _publicRoutes = <String>{
    RouteNames.splash,
    RouteNames.login,
    RouteNames.register,
    RouteNames.forgotPassword,
  };

  static Future<String?> redirect(_, GoRouterState state) async {
    final location = state.uri.toString();
    final isPublic = _publicRoutes.any((r) => location.startsWith(r));

    // Lazy access – avoids injecting SecureStorage into GoRouter constructor
    final storage = SecureStorage();
    final token = await storage.getAccessToken();
    final isAuthenticated = token != null;

    if (!isAuthenticated && !isPublic) return RouteNames.login;
    if (isAuthenticated && location == RouteNames.login) return RouteNames.dashboard;

    return null;
  }
}
