import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';

/// Handles all authentication operations via Supabase Auth.
/// Creates profiles in the `public.profiles` table on signup.
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  static const _uuid = Uuid();

  /// Get the current authenticated user's ID, or null.
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Get the current session.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up a new Personal user.
  Future<Profile> signUpPersonal({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'personal',
      },
    );

    if (response.user == null) {
      throw Exception('Signup failed: no user returned');
    }

    // Create profile row
    final profile = Profile(
      id: response.user!.id,
      role: UserRole.personal,
      fullName: fullName,
      email: email,
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _client.from('profiles').upsert(profile.toJson());
    return profile;
  }

  /// Sign up a new Business Employee.
  /// Employee ID is auto-generated as a short UUID-based code.
  Future<Profile> signUpEmployee({
    required String email,
    required String password,
    required String fullName,
    required String companyDomain,
    String? nickname,
  }) async {
    final employeeId = 'EMP-${_uuid.v4().substring(0, 8).toUpperCase()}';

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'employee',
        'company_domain': companyDomain,
        'employee_id': employeeId,
      },
    );

    if (response.user == null) {
      throw Exception('Signup failed: no user returned');
    }

    final profile = Profile(
      id: response.user!.id,
      role: UserRole.employee,
      companyDomain: companyDomain,
      employeeId: employeeId,
      fullName: fullName,
      nickname: nickname,
      email: email,
      isOnline: true,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _client.from('profiles').upsert(profile.toJson());
    return profile;
  }

  /// Sign in with email and password.
  Future<Profile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed. Please try again.');
      }

      // Fetch full profile
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      // Update online status
      await _client
          .from('profiles')
          .update({'is_online': true, 'last_seen': DateTime.now().toIso8601String()})
          .eq('id', response.user!.id);

      return Profile.fromJson(data);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Invalid email or password. Please check and try again.');
      }
      throw Exception(e.message);
    }
  }

  /// Get the current user's profile.
  Future<Profile?> getCurrentProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Sign out and set offline.
  Future<void> signOut() async {
    final userId = currentUserId;
    if (userId != null) {
      await _client
          .from('profiles')
          .update({'is_online': false, 'last_seen': DateTime.now().toIso8601String()})
          .eq('id', userId);
    }
    await _client.auth.signOut();
  }

  /// Create a Business Admin account (only callable by Super Admin).
  Future<Profile> createBusinessAdmin({
    required String email,
    required String password,
    required String fullName,
    required String companyDomain,
  }) async {
    // Use admin signup - the super admin creates the account
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'business_admin',
        'company_domain': companyDomain,
      },
    );

    if (response.user == null) {
      throw Exception('Failed to create business admin');
    }

    final profile = Profile(
      id: response.user!.id,
      role: UserRole.businessAdmin,
      companyDomain: companyDomain,
      fullName: fullName,
      email: email,
      isOnline: false,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _client.from('profiles').upsert(profile.toJson());
    return profile;
  }

  /// Create an Employee account (only callable by Business Admin).
  Future<Profile> createEmployee({
    required String email,
    required String password,
    required String fullName,
    required String companyDomain,
    String? nickname,
  }) async {
    final employeeId = 'EMP-${_uuid.v4().substring(0, 8).toUpperCase()}';

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'employee',
        'company_domain': companyDomain,
        'employee_id': employeeId,
      },
    );

    if (response.user == null) {
      throw Exception('Failed to create employee');
    }

    final profile = Profile(
      id: response.user!.id,
      role: UserRole.employee,
      companyDomain: companyDomain,
      employeeId: employeeId,
      fullName: fullName,
      nickname: nickname,
      email: email,
      isOnline: false,
      lastSeen: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await _client.from('profiles').upsert(profile.toJson());
    return profile;
  }

  /// Update the current user's password.
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Update profile fields (status, avatar, nickname, etc.).
  Future<void> updateProfile({
    String? statusText,
    String? avatarUrl,
    String? nickname,
    String? fullName,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (statusText != null) updates['status_text'] = statusText;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (nickname != null) updates['nickname'] = nickname;
    if (fullName != null) updates['full_name'] = fullName;

    if (updates.isNotEmpty) {
      await _client.from('profiles').update(updates).eq('id', userId);
    }
  }

  /// Upload an avatar image and return the public URL.
  Future<String> uploadAvatar(List<int> fileBytes, String fileName) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final path = '$userId/$fileName';
    await _client.storage.from('avatars').uploadBinary(
      path,
      fileBytes as dynamic,
      fileOptions: const FileOptions(upsert: true),
    );

    return _client.storage.from('avatars').getPublicUrl(path);
  }
}
