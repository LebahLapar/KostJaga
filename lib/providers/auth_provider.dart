import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  String? _userRole; // 'owner' or 'tenant'
  String? _tenantId; // For tenant users
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get userRole => _userRole;
  String? get tenantId => _tenantId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isOwner => _userRole == 'owner';
  bool get isTenant => _userRole == 'tenant';

  AuthProvider() {
    _checkUser();
  }

  void _checkUser() {
    _user = _supabase.auth.currentUser;
    if (_user != null) {
      _loadUserRole();
    }
    notifyListeners();
  }

  Future<void> _loadUserRole() async {
    if (_user == null) return;

    try {
      // Cek apakah user adalah tenant
      final tenantData = await _supabase
          .from('tenants')
          .select('id, can_login')
          .eq('user_id', _user!.id)
          .maybeSingle();

      if (tenantData != null && tenantData['can_login'] == true) {
        _userRole = 'tenant';
        _tenantId = tenantData['id'];
      } else {
        _userRole = 'owner';
        _tenantId = null;
      }

      await _saveUserLocally();
      notifyListeners();
    } catch (e) {
      print('Error loading user role: $e');
      _userRole = 'owner'; // Default to owner
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'owner', // Default role
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );

      if (response.user != null) {
        _user = response.user;
        _userRole = role;
        await _saveUserLocally();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        await _loadUserRole(); // Load role after login
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    _userRole = null;
    _tenantId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> _saveUserLocally() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('user_id', _user!.id);
      await prefs.setString('user_email', _user!.email ?? '');
      if (_userRole != null) {
        await prefs.setString('user_role', _userRole!);
      }
      if (_tenantId != null) {
        await prefs.setString('tenant_id', _tenantId!);
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}