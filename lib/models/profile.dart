/// User roles in Chatizy.
/// Maps directly to the Postgres `user_role` enum.
enum UserRole {
  superAdmin('super_admin'),
  businessAdmin('business_admin'),
  employee('employee'),
  personal('personal');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String s) {
    return UserRole.values.firstWhere(
      (r) => r.value == s,
      orElse: () => UserRole.personal,
    );
  }
}

/// Profile model matching the `public.profiles` table.
class Profile {
  final String id;
  final UserRole role;
  final String? companyDomain;
  final String? employeeId;
  final String fullName;
  final String? nickname;
  final String? email;
  final String? avatarUrl;
  final String? statusText;
  final bool isOnline;
  final DateTime lastSeen;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.role,
    this.companyDomain,
    this.employeeId,
    required this.fullName,
    this.nickname,
    this.email,
    this.avatarUrl,
    this.statusText,
    required this.isOnline,
    required this.lastSeen,
    required this.createdAt,
  });

  /// Display name: nickname if set, otherwise full name.
  String get displayName => nickname ?? fullName;

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'personal'),
      companyDomain: json['company_domain'] as String?,
      employeeId: json['employee_id'] as String?,
      fullName: json['full_name'] as String? ?? 'Unknown',
      nickname: json['nickname'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      statusText: json['status_text'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen: DateTime.tryParse(json['last_seen'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.value,
      'company_domain': companyDomain,
      'employee_id': employeeId,
      'full_name': fullName,
      'nickname': nickname,
      'email': email,
      'avatar_url': avatarUrl,
      'status_text': statusText,
      'is_online': isOnline,
      'last_seen': lastSeen.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
