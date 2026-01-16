import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/features/app_features/views/features_page.dart';
import 'package:school_management_system/features/auth/views/forget_pass_page.dart';
import 'package:school_management_system/features/chat/views/chat_page.dart';
import 'package:school_management_system/features/dashboard/views/dashboard_page.dart';
import 'package:school_management_system/features/profile/views/profile_page.dart';

import '../../features/auth/views/splash_page.dart';
import 'nave_bar_page.dart';
import 'route_paths.dart';

import '../../features/auth/views/login_page.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );
  late GoRouter router;
  NavigationService() {
    router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: Routes.splash,
      routes: [
        // Auth routes - outside the bottom nav bar
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: Routes.forgotPassword,
          builder: (context, state) => const ForgetPassPage(),
        ),

        /// Bottom Navigation Bar with nested routes
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            debugPrint(
              'NavigationShell current index: ${navigationShell.currentIndex}',
            );
            return NavBarScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'home'),
              routes: [
                GoRoute(
                  path: Routes.home,
                  builder: (context, state) => const DashboardPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'features'),
              routes: [
                GoRoute(
                  path: Routes.features,
                  builder: (context, state) => FeaturesPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'chat'),
              routes: [
                GoRoute(
                  path: Routes.chat,
                  builder: (context, state) => const ChatPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'profile'),
              routes: [
                GoRoute(
                  path: Routes.profile,
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
