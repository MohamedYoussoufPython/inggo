import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/admin_theme.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/drivers/presentation/pages/drivers_page.dart';
import '../features/rides/presentation/pages/rides_page.dart';
import '../features/finance/presentation/pages/finance_page.dart';
import '../features/users/presentation/pages/users_page.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'widgets/admin_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final adminRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AdminShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardPage(),
          ),
        ),
        GoRoute(
          path: '/drivers',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DriversPage(),
          ),
        ),
        GoRoute(
          path: '/rides',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: RidesPage(),
          ),
        ),
        GoRoute(
          path: '/finance',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FinancePage(),
          ),
        ),
        GoRoute(
          path: '/users',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: UsersPage(),
          ),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MapPage(),
          ),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: NotificationsPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Inggo Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.theme,
      routerConfig: adminRouter,
    );
  }
}
