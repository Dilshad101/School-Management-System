import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../auth/session.dart';
import '../storage/local_storage.dart';
import '../tenant/tenant_context.dart';
import '../router/app_router.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/repositories/user_repository.dart';
import '../../features/students/repositories/students_repository.dart';

final locator = GetIt.instance;

/// Global navigator key (optional but useful for dialogs/snackbars)
GlobalKey<NavigatorState> get navigatorKey =>
    locator<GlobalKey<NavigatorState>>();

Future<void> setupDependency() async {
  /// -------------------------------
  /// Storage
  /// -------------------------------
  final sharedPref = SharedPref();
  await sharedPref.init();

  /// -------------------------------
  /// Core singletons
  /// -------------------------------
  locator
    ..registerSingleton<SharedPref>(sharedPref)
    // Holds the current logged-in session (null if logged out)
    ..registerSingleton<SessionHolder>(SessionHolder())
    // Holds selected school (mainly for super admin)
    ..registerSingleton<TenantContext>(TenantContext())
    // Global navigator key
    ..registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());

  /// -------------------------------
  /// Networking
  /// -------------------------------
  locator.registerSingleton<ApiClient>(
    ApiClient(
      sessionProvider: () => locator<SessionHolder>().session,
      tenantContext: locator<TenantContext>(),
    ),
  );

  /// -------------------------------
  /// Router
  /// -------------------------------
  locator.registerSingleton<NavigationService>(NavigationService());

  /// -------------------------------
  /// Repositories
  /// -------------------------------
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator<ApiClient>()),
  );

  locator.registerLazySingleton<UserRepository>(
    () => UserRepository(locator<ApiClient>()),
  );

  locator.registerLazySingleton<StudentsRepository>(
    () => StudentsRepository(apiClient: locator<ApiClient>()),
  );
}

/// Simple holder for Session (keeps DI clean)
class SessionHolder {
  Session? session;
}
