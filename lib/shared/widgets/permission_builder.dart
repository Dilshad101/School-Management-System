import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/blocs/user/user_bloc.dart';

/// A widget that conditionally renders its child based on user permissions.
///
/// Usage:
/// ```dart
/// PermissionBuilder(
///   permission: Permissions.viewStudent,
///   builder: (context, hasPermission) {
///     if (!hasPermission) return SizedBox.shrink();
///     return YourWidget();
///   },
/// )
/// ```
///
/// Or with a fallback:
/// ```dart
/// PermissionBuilder(
///   permission: Permissions.viewStudent,
///   child: YourWidget(),
///   fallback: NoPermissionWidget(),
/// )
/// ```
class PermissionBuilder extends StatelessWidget {
  const PermissionBuilder({
    super.key,
    this.permission,
    this.permissions,
    this.requireAll = false,
    this.builder,
    this.child,
    this.fallback,
  }) : assert(
         permission != null || permissions != null,
         'Either permission or permissions must be provided',
       ),
       assert(
         builder != null || child != null,
         'Either builder or child must be provided',
       );

  /// Single permission to check.
  final String? permission;

  /// Multiple permissions to check.
  final List<String>? permissions;

  /// If true, requires all permissions. If false, requires any permission.
  /// Only applies when [permissions] is provided.
  final bool requireAll;

  /// Builder function that receives whether the user has permission.
  final Widget Function(BuildContext context, bool hasPermission)? builder;

  /// Child widget to show if permission is granted.
  final Widget? child;

  /// Widget to show if permission is denied. Defaults to SizedBox.shrink().
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final hasPermission = _checkPermission(state);

        if (builder != null) {
          return builder!(context, hasPermission);
        }

        if (hasPermission) {
          return child!;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }

  bool _checkPermission(UserState state) {
    if (permission != null) {
      return state.hasPermission(permission!);
    }

    if (permissions != null) {
      if (requireAll) {
        return state.hasAllPermissions(permissions!);
      } else {
        return state.hasAnyPermission(permissions!);
      }
    }

    return false;
  }
}

/// Extension on BuildContext for easy permission checking.
extension PermissionContext on BuildContext {
  /// Check if current user has a specific permission.
  bool hasPermission(String permission) {
    return read<UserBloc>().state.hasPermission(permission);
  }

  /// Check if current user has all of the specified permissions.
  bool hasAllPermissions(List<String> permissions) {
    return read<UserBloc>().state.hasAllPermissions(permissions);
  }

  /// Check if current user has any of the specified permissions.
  bool hasAnyPermission(List<String> permissions) {
    return read<UserBloc>().state.hasAnyPermission(permissions);
  }

  /// Get the current user's permissions list.
  List<String> get userPermissions {
    return read<UserBloc>().state.user?.permissions ?? [];
  }
}

/// A mixin for Cubits/Blocs that need to check permissions before API calls.
mixin PermissionCheckMixin {
  /// Check if the user has the required permission.
  /// Returns true if permission is granted, false otherwise.
  bool checkPermission(BuildContext context, String permission) {
    return context.hasPermission(permission);
  }

  /// Check if the user has all required permissions.
  bool checkAllPermissions(BuildContext context, List<String> permissions) {
    return context.hasAllPermissions(permissions);
  }

  /// Check if the user has any of the required permissions.
  bool checkAnyPermission(BuildContext context, List<String> permissions) {
    return context.hasAnyPermission(permissions);
  }
}
