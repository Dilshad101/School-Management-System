import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_management_system/core/storage/local_storage.dart';
import 'package:school_management_system/core/utils/di.dart';
import 'package:school_management_system/features/auth/blocs/auth/auth_bloc.dart';
import 'package:school_management_system/features/auth/blocs/user/user_bloc.dart';
import 'package:school_management_system/features/auth/repositories/auth_repository.dart';
import 'package:school_management_system/features/auth/repositories/user_repository.dart';

final providers = [
  /// AuthBloc - manage authentication state
  BlocProvider<AuthBloc>(
    create: (context) => AuthBloc(
      authRepository: locator<AuthRepository>(),
      sharedPref: locator<SharedPref>(),
    )..add(const AuthCheckRequested()),
  ),

  /// UserBloc - manage user details
  BlocProvider<UserBloc>(
    create: (context) => UserBloc(userRepository: locator<UserRepository>()),
  ),
];
