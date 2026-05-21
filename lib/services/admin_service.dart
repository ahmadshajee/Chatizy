import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

/// Admin-specific operations for Business Admin and Super Admin dashboards.
class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── Business Admin Operations ───────────────────────────────────────

  /// Get all employees in the admin's company domain with online status.
  Future<List<Profile>> getCompanyEmployees(String companyDomain) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('company_domain', companyDomain)
        .order('is_online', ascending: false)
        .order('last_seen', ascending: false);

    return (data as List).map((json) => Profile.fromJson(json)).toList();
  }

  /// Get online employee count for a domain.
  Future<int> getOnlineCount(String companyDomain) async {
    final data = await _client
        .from('profiles')
        .select('id')
        .eq('company_domain', companyDomain)
        .eq('is_online', true);

    return (data as List).length;
  }

  /// Get total employee count for a domain.
  Future<int> getTotalEmployeeCount(String companyDomain) async {
    final data = await _client
        .from('profiles')
        .select('id')
        .eq('company_domain', companyDomain);

    return (data as List).length;
  }

  /// Get recent message activity (metadata only - WHO contacted WHOM).
  /// Does NOT return message content for compliance.
  Future<List<Map<String, dynamic>>> getRecentActivity(String companyDomain) async {
    final data = await _client
        .from('messages')
        .select('sender_name, receiver_domain, created_at')
        .eq('receiver_domain', companyDomain)
        .order('created_at', ascending: false)
        .limit(20);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Get today's message count for a domain.
  Future<int> getTodayMessageCount(String companyDomain) async {
    final today = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(today.year, today.month, today.day);

    final data = await _client
        .from('messages')
        .select('id')
        .eq('receiver_domain', companyDomain)
        .gte('created_at', startOfDay.toIso8601String());

    return (data as List).length;
  }

  /// Subscribe to employee online status changes in real-time.
  RealtimeChannel subscribeToEmployeeStatus(
    String companyDomain,
    void Function() onStatusChange,
  ) {
    return _client
        .channel('profiles:$companyDomain')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_domain',
            value: companyDomain,
          ),
          callback: (_) => onStatusChange(),
        )
        .subscribe();
  }

  // ─── Super Admin Operations ──────────────────────────────────────────

  /// Get all business admins across all domains.
  Future<List<Profile>> getAllBusinessAdmins() async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('role', 'business_admin')
        .order('created_at', ascending: false);

    return (data as List).map((json) => Profile.fromJson(json)).toList();
  }

  /// Get employee count for a specific domain (for super admin overview).
  Future<Map<String, int>> getEmployeeCountsByDomain() async {
    final admins = await getAllBusinessAdmins();
    final counts = <String, int>{};

    for (final admin in admins) {
      if (admin.companyDomain != null) {
        final count = await getTotalEmployeeCount(admin.companyDomain!);
        counts[admin.companyDomain!] = count;
      }
    }

    return counts;
  }

  /// Get total employees across all domains (for super admin stat).
  Future<int> getTotalEmployeesAllDomains() async {
    final data = await _client
        .from('profiles')
        .select('id')
        .eq('role', 'employee');

    return (data as List).length;
  }
}
