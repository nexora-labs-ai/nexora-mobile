import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/bindings/injection_container.dart';
import '../../core/router/auth_guard.dart';
import '../../core/router/go_router_refresh_stream.dart';
import '../../features/activity/presentation/cubit/activity_cubit.dart';
import '../../features/activity/presentation/pages/activity_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/cubit/expense_cubit.dart';
import '../../features/expenses/presentation/pages/create_expense_page.dart';
import '../../features/expenses/presentation/pages/expense_detail_page.dart';
import '../../features/expenses/presentation/pages/expense_list_page.dart';
import '../../features/group_chat/presentation/pages/group_chat_screen.dart';
import '../../features/groups/presentation/cubit/group_cubit.dart';
import '../../features/groups/presentation/pages/create_group_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import '../../features/groups/presentation/pages/group_fund_page.dart';
import '../../features/groups/presentation/pages/group_list_page.dart';
import '../../features/groups/presentation/pages/group_members_page.dart';
import '../../features/groups/presentation/pages/group_settings_page.dart';
import '../../features/groups/presentation/pages/invite_member_page.dart';
import '../../features/itinerary/data/models/itinerary_model.dart';
import '../../features/itinerary/presentation/pages/itinerary_detail_page.dart';
import '../../features/itinerary/presentation/pages/itinerary_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settlements/presentation/screens/settlements_screen.dart';
import '../../shared/widgets/splash_screen.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithBottomNav(navigationShell: navigationShell),
        branches: [
          // Branch 0: Dashboard (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                builder: (_, __) => const DashboardPage(),
              ),
              GoRoute(
                path: RouteNames.settlements,
                builder: (_, __) => const SettlementsScreen(groupId: ''),
              ),
            ],
          ),
          // Branch 1: Groups
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.groups,
                builder: (_, __) => const GroupListPage(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (_, __) => const CreateGroupPage(),
                  ),
                  ShellRoute(
                    builder: (context, state, child) {
                      final groupId = state.pathParameters['groupId'];
                      if (groupId == null) return child;
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) =>
                                sl<GroupCubit>()..loadGroupDetail(groupId),
                          ),
                          BlocProvider(
                            create: (_) => sl<ActivityCubit>()
                              ..fetchActivities(groupId: groupId),
                          ),
                          BlocProvider(
                            create: (_) =>
                                sl<ExpenseCubit>()..loadExpenses(groupId),
                          ),
                        ],
                        child: child,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':groupId',
                        builder: (_, state) => GroupDetailPage(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                      GoRoute(
                        path: ':groupId/invite',
                        builder: (_, state) => InviteMemberPage(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                      GoRoute(
                        path: ':groupId/settings',
                        builder: (_, state) => GroupSettingsPage(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                      GoRoute(
                        path: ':groupId/members',
                        builder: (_, state) => GroupMembersPage(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                      GoRoute(
                        path: ':groupId/itinerary',
                        builder: (_, state) => ItineraryPage(
                          groupId: state.pathParameters['groupId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: ':itineraryId',
                            builder: (_, state) => ItineraryDetailPage(
                              groupId: state.pathParameters['groupId']!,
                              itinerary: state.extra as ItineraryModel,
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: ':groupId/settlements',
                        builder: (_, state) => SettlementsScreen(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                      GoRoute(
                        path: ':groupId/fund',
                        builder: (_, state) => GroupFundPage(
                          groupId: state.pathParameters['groupId']!,
                        ),
                      ),
                      GoRoute(
                        path: ':groupId/expenses',
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
                          GoRoute(
                            path: ':expenseId',
                            builder: (_, state) => ExpenseDetailPage(
                              groupId: state.pathParameters['groupId']!,
                              expenseId: state.pathParameters['expenseId']!,
                            ),
                          ),
                          GoRoute(
                            path: ':expenseId/edit',
                            builder: (_, state) => CreateExpensePage(
                              groupId: state.pathParameters['groupId']!,
                              expenseId: state.pathParameters['expenseId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':groupId/chat',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) {
                      final groupId = state.pathParameters['groupId']!;
                      return BlocProvider(
                        create: (_) =>
                            sl<GroupCubit>()..loadGroupDetail(groupId),
                        child: GroupChatScreen(groupId: groupId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Activity
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.activity,
                builder: (_, __) => const ActivityPage(),
              ),
            ],
          ),
          // Branch 3: AI Chat
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.aiAssistant,
                builder: (_, __) => const ChatPage(groupId: ''),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (_, __) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, __) => const EditProfilePage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Bottom navigation shell scaffold.
class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        selectedIndex: navigationShell.currentIndex,
        backgroundColor: const Color(0xFFF6F8F3), // AppColors.canvas
        indicatorColor: const Color(0xFF9FE870), // AppColors.primaryContainer
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
              icon: Icon(Icons.local_activity_outlined),
              selectedIcon: Icon(Icons.local_activity),
              label: 'Activity'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'AI Chat'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}
