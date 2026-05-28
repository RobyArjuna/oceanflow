import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/shipment/presentation/screens/shipment_list_screen.dart';
import '../features/shipment/presentation/screens/shipment_detail_screen.dart';
import '../features/tracking/presentation/screens/tracking_update_screen.dart';
import '../features/sync/presentation/screens/sync_dashboard_screen.dart';
import '../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../features/notifications/presentation/screens/notification_center_screen.dart';
import '../shared/widgets/role_guard.dart';
import '../core/auth/auth_state.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == RouteNames.login;
      final isSplashing = state.matchedLocation == RouteNames.splash;
      final isAuthenticated = authState.status == AuthStatus.authenticated;

      if (authState.status == AuthStatus.initial || authState.status == AuthStatus.loading) {
        return isSplashing ? null : RouteNames.splash;
      }

      if (!isAuthenticated) {
        return isLoggingIn ? null : RouteNames.login;
      }

      if (isLoggingIn || isSplashing) {
        return RouteNames.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellLayout(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.shipments,
            builder: (context, state) => const ShipmentListScreen(),
            routes: [
              GoRoute(
                path: RouteNames.shipmentDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return ShipmentDetailScreen(shipmentId: id);
                },
                routes: [
                  GoRoute(
                    path: RouteNames.trackingUpdate,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return TrackingUpdateScreen(shipmentId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.sync,
            builder: (context, state) => const RoleGuard(
              allowedRoles: [UserRole.admin, UserRole.supervisor],
              child: SyncDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.aiAssistant,
            builder: (context, state) => const AiAssistantScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            builder: (context, state) => const NotificationCenterScreen(),
          ),
        ],
      ),
    ],
  );
});

class MainShellLayout extends ConsumerWidget {
  final Widget child;

  const MainShellLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(authStateProvider).user;
    final role = user?.role ?? UserRole.operator;

    // Filter dynamic navigation items based on UserRole
    final tabs = [
      (RouteNames.dashboard, Icons.dashboard_outlined, 'Dashboard'),
      (RouteNames.shipments, Icons.local_shipping_outlined, 'Shipments'),
      if (role == UserRole.admin || role == UserRole.supervisor)
        (RouteNames.sync, Icons.sync_outlined, 'Sync Queue'),
      (RouteNames.aiAssistant, Icons.psychology_outlined, 'AI Assistant'),
      (RouteNames.notifications, Icons.notifications_outlined, 'Notifications'),
    ];

    int activeIndex = tabs.indexWhere((tab) => location.startsWith(tab.$1));
    if (activeIndex == -1) activeIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeIndex,
        onDestinationSelected: (index) {
          context.go(tabs[index].$1);
        },
        destinations: tabs.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.$2),
            label: tab.$3,
          );
        }).toList(),
      ),
    );
  }
}
