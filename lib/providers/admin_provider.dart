import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/admin_service.dart';

/// Manages admin dashboard state for Business Admin and Super Admin views.
class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  // Business Admin state
  List<Profile> _employees = [];
  List<Map<String, dynamic>> _recentActivity = [];
  int _onlineCount = 0;
  int _totalEmployees = 0;
  int _todayMessages = 0;

  // Super Admin state
  List<Profile> _businessAdmins = [];
  Map<String, int> _employeeCountsByDomain = {};
  int _totalEmployeesAllDomains = 0;

  bool _isLoading = false;
  RealtimeChannel? _statusChannel;

  // Getters
  List<Profile> get employees => _employees;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;
  int get onlineCount => _onlineCount;
  int get totalEmployees => _totalEmployees;
  int get todayMessages => _todayMessages;
  List<Profile> get businessAdmins => _businessAdmins;
  Map<String, int> get employeeCountsByDomain => _employeeCountsByDomain;
  int get totalEmployeesAllDomains => _totalEmployeesAllDomains;
  bool get isLoading => _isLoading;

  // ─── Business Admin Dashboard ────────────────────────────────────────

  /// Load all dashboard data for a Business Admin.
  Future<void> loadBusinessDashboard(String companyDomain) async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = await Future.wait([
        _adminService.getCompanyEmployees(companyDomain),
        _adminService.getOnlineCount(companyDomain),
        _adminService.getTotalEmployeeCount(companyDomain),
        _adminService.getRecentActivity(companyDomain),
        _adminService.getTodayMessageCount(companyDomain),
      ]);

      _employees = futures[0] as List<Profile>;
      _onlineCount = futures[1] as int;
      _totalEmployees = futures[2] as int;
      _recentActivity = futures[3] as List<Map<String, dynamic>>;
      _todayMessages = futures[4] as int;

      // Subscribe to real-time status updates
      _statusChannel?.unsubscribe();
      _statusChannel = _adminService.subscribeToEmployeeStatus(
        companyDomain,
        () => loadBusinessDashboard(companyDomain),
      );
    } catch (e) {
      debugPrint('Error loading business dashboard: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Super Admin Dashboard ───────────────────────────────────────────

  /// Load all dashboard data for a Super Admin.
  Future<void> loadSuperDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _businessAdmins = await _adminService.getAllBusinessAdmins();
      _employeeCountsByDomain = await _adminService.getEmployeeCountsByDomain();
      _totalEmployeesAllDomains = await _adminService.getTotalEmployeesAllDomains();
    } catch (e) {
      debugPrint('Error loading super dashboard: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _statusChannel?.unsubscribe();
    super.dispose();
  }
}
