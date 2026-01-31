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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Only navigate when auth check is complete (not initial or loading)
        if (state.isAuthenticated) {
          // User is logged in, fetch user details and go home
          context.read<UserBloc>().add(const UserDetailsFetchRequested());
          context.go(Routes.home);
        } else if (state.isUnauthenticated) {
          // User is not logged in, go to login
          context.go(Routes.login);
        }
        // If state.status == AuthStatus.initial, wait for AuthCheckRequested to complete
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
