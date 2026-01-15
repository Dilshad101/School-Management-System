import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/views/splash_page.dart';
import 'route_paths.dart';

// Pages (create minimal placeholders for now)
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
      ],
    );
  }
}
