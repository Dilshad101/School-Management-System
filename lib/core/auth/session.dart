// Manages user session and authentication state.
// Holds the authenticated user session.
// Keep it simple at the start; expand as needed.

enum UserRole { superAdmin, schoolAdmin, teacher, parent, student }

class Session {
  final String accessToken;
  final String userId;
  final UserRole role;

  /// For non-super-admin users, this is their fixed school scope.
  /// For super admin, this can be null.
  final String? schoolId;

  const Session({
    required this.accessToken,
    required this.userId,
    required this.role,
    this.schoolId,
  });

  bool get isSuperAdmin => role == UserRole.superAdmin;
}
