import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/core/storage/local_storage.dart';
import 'package:school_management_system/core/utils/di.dart';
import 'package:school_management_system/features/auth/blocs/auth/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthBloc>().add(AuthLogoutRequested());
            context.go(Routes.login);
          },
          child: Text('Log Out'),
        ),
      ),
    );
  }
}

//https://api.dev.waad.co.in/api/v1/student-users/?page=1&pagesize=10&search=
//https://api.dev.waad.co.in/api/v1/student-users/?page=1&pagesize=10
