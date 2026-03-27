import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/features/auth/blocs/auth/auth_bloc.dart';
import 'package:school_management_system/features/auth/blocs/user/user_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.isAuthenticated) {
              // User is logged in, fetch user details
              context.read<UserBloc>().add(const UserDetailsFetchRequested());
            } else if (state.isUnauthenticated) {
              // User is not logged in, go to login
              context.go(Routes.login);
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            // Navigate to home only after user details are fetched
            if (state.status == UserStatus.success) {
              context.go(Routes.home);
            } else if (state.status == UserStatus.failure) {
              // If user details fail, still go to home (will show error there)
              // or alternatively go to login
              context.go(Routes.home);
            }
          },
        ),
      ],
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
