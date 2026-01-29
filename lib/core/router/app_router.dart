import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/features/app_features/views/features_page.dart';
import 'package:school_management_system/features/attendance/views/attendance_view.dart';
import 'package:school_management_system/features/auth/views/forget_pass_page.dart';
import 'package:school_management_system/features/chat/views/chat_page.dart';
import 'package:school_management_system/features/class/views/class_details_view/class_details_view.dart';
import 'package:school_management_system/features/class/views/class_view/class_view.dart';
import 'package:school_management_system/features/class/views/create_class_view/create_class_view.dart';
import 'package:school_management_system/features/dashboard/views/dashboard_page.dart';
import 'package:school_management_system/features/employees/views/employees_view.dart';
import 'package:school_management_system/features/fees/views/fees_view/fees_view.dart';
import 'package:school_management_system/features/guardians/view/guardian_view.dart';
import 'package:school_management_system/features/profile/views/profile_page.dart';
import 'package:school_management_system/features/students/views/students_view.dart';
import 'package:school_management_system/features/user_request/views/user_request_view.dart';

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
        GoRoute(
          path: Routes.employees,
          builder: (context, state) => const EmployeesView(),
        ),
        GoRoute(
          path: Routes.students,
          builder: (context, state) => const StudentsView(),
        ),
        GoRoute(
          path: Routes.classes,
          builder: (context, state) => const ClassView(),
        ),
        GoRoute(
          path: Routes.classDetail,
          builder: (context, state) {
            final classId = state.extra as String?;
            return ClassDetailsView(classId: classId);
          },
        ),
        GoRoute(
          path: Routes.createClass,
          builder: (context, state) => const CreateClassView(),
        ),
        GoRoute(
          path: Routes.guardians,
          builder: (context, state) => const GuardianView(),
        ),
        GoRoute(
          path: Routes.attendance,
          builder: (context, state) => const AttendanceView(),
        ),
        GoRoute(
          path: Routes.fees,
          builder: (context, state) => const FeesView(),
        ),
        GoRoute(
          path: Routes.userRequests,
          builder: (context, state) => const UserRequestView(),
        ),

        /// Bottom Navigation Bar with nested routes
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
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
