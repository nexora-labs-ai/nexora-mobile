import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/bindings/injection_container.dart';
import '../../app/router/route_names.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

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

  static String? redirect(BuildContext context, GoRouterState state) {
    final location = state.uri.toString();
    final isPublic = _publicRoutes.any((r) {
      if (r == RouteNames.splash) return location == '/';
      return location.startsWith(r);
    });

    final authState = sl<AuthCubit>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    if (!isAuthenticated && !isPublic) return RouteNames.login;

    final isAuthRoute = location == RouteNames.login ||
        location == RouteNames.register ||
        location == RouteNames.forgotPassword;
    if (isAuthenticated && isAuthRoute) return RouteNames.dashboard;

    return null;
  }
}
