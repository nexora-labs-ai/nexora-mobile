import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/bindings/injection_container.dart';
import '../../core/router/auth_guard.dart';
import '../../core/router/go_router_refresh_stream.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/create_expense_page.dart';
import '../../features/expenses/presentation/pages/expense_list_page.dart';
import '../../features/groups/presentation/pages/create_group_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import '../../features/groups/presentation/pages/group_fund_page.dart';
import '../../features/groups/presentation/pages/group_list_page.dart';
import '../../features/groups/presentation/pages/group_members_page.dart';
import '../../features/groups/presentation/pages/group_settings_page.dart';
import '../../features/groups/presentation/pages/invite_member_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/splash_screen.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: AuthGuard.redirect,
    refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),

      // ── Auth ────────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterPage(),
      ),

      // ── Shell (Bottom Navigation) ────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: RouteNames.groups,
            builder: (_, __) => const GroupListPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateGroupPage(),
              ),
              GoRoute(
                path: ':groupId',
                builder: (_, state) => GroupDetailPage(
                  groupId: state.pathParameters['groupId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'invite',
                    builder: (_, state) => InviteMemberPage(
                      groupId: state.pathParameters['groupId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (_, state) => GroupSettingsPage(
                      groupId: state.pathParameters['groupId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'members',
                    builder: (_, state) => GroupMembersPage(
                      groupId: state.pathParameters['groupId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'expenses',
                    builder: (_, state) => ExpenseListPage(
                      groupId: state.pathParameters['groupId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'create',
                        builder: (_, state) => CreateExpensePage(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'chat',
                    builder: (_, state) => ChatPage(
                      groupId: state.pathParameters['groupId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'fund',
                    builder: (_, state) => GroupFundPage(
                      groupId: state.pathParameters['groupId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (_, __) => const NotificationsPage(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}

/// Bottom navigation shell scaffold.
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => _onTabSelected(context, index),
        selectedIndex: _selectedIndex(context),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.group_outlined),
              selectedIcon: Icon(Icons.group),
              label: 'Groups'),
          NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Alerts'),
          NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.groups)) return 1;
    if (location.startsWith(RouteNames.notifications)) return 2;
    if (location.startsWith(RouteNames.profile)) return 3;
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
      case 1:
        context.go(RouteNames.groups);
      case 2:
        context.go(RouteNames.notifications);
      case 3:
        context.go(RouteNames.profile);
    }
  }
}
