import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantAuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  String? _tenantId;
  String? _tenantName;
  String? _roomId;
  String? _roomCode;
  String? _roomNumber;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String? get tenantId => _tenantId;
  String? get tenantName => _tenantName;
  String? get roomId => _roomId;
  String? get roomCode => _roomCode;
  String? get roomNumber => _roomNumber;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _tenantId != null;

  // Login dengan room code + PIN
  Future<bool> loginWithRoomCode({
    required String roomCode,
    required String pinCode,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Call Supabase function untuk verify login
      final response = await _supabase.rpc(
        'verify_tenant_login',
        params: {
          'p_room_code': roomCode,
          'p_pin_code': pinCode,
        },
      );

      // Parse response
      if (response is List && response.isNotEmpty) {
        final data = response[0];
        final isValid = data['is_valid'] as bool?;

        if (isValid == true) {
          // Login success - save tenant data
          _tenantId = data['tenant_id'] as String?;
          _tenantName = data['tenant_name'] as String?;
          _roomId = data['room_id'] as String?;
          _roomNumber = data['room_number'] as String?;
          _roomCode = roomCode;

          // Save to local storage
          await _saveToLocalStorage();

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // Invalid credentials
          _errorMessage = 'Kode kamar atau PIN salah';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Kode kamar atau PIN salah';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if already logged in (dari local storage)
  Future<bool> checkExistingLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTenantId = prefs.getString('tenant_id');
      final savedRoomCode = prefs.getString('tenant_room_code');
      final savedPinCode = prefs.getString('tenant_pin_code');

      if (savedTenantId != null && 
          savedRoomCode != null && 
          savedPinCode != null) {
        // Re-verify credentials
        return await loginWithRoomCode(
          roomCode: savedRoomCode,
          pinCode: savedPinCode,
        );
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _tenantId = null;
      _tenantName = null;
      _roomId = null;
      _roomCode = null;
      _roomNumber = null;
      _errorMessage = null;

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tenant_id');
      await prefs.remove('tenant_name');
      await prefs.remove('tenant_room_id');
      await prefs.remove('tenant_room_code');
      await prefs.remove('tenant_room_number');
      await prefs.remove('tenant_pin_code');

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal logout: ${e.toString()}';
      notifyListeners();
    }
  }

  // Save credentials to local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_tenantId != null) await prefs.setString('tenant_id', _tenantId!);
      if (_tenantName != null) await prefs.setString('tenant_name', _tenantName!);
      if (_roomId != null) await prefs.setString('tenant_room_id', _roomId!);
      if (_roomCode != null) await prefs.setString('tenant_room_code', _roomCode!);
      if (_roomNumber != null) await prefs.setString('tenant_room_number', _roomNumber!);
    } catch (e) {
      // Silent fail - not critical
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get tenant full data from database
  Future<Map<String, dynamic>?> getTenantData() async {
    if (_tenantId == null) return null;

    try {
      final response = await _supabase
          .from('tenant_login_view')
          .select()
          .eq('tenant_id', _tenantId!)
          .single();

      return response;
    } catch (e) {
      _errorMessage = 'Gagal mengambil data tenant: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Get tenant complaints
  Future<List<Map<String, dynamic>>> getTenantComplaints() async {
    if (_tenantId == null) return [];

    try {
      final response = await _supabase
          .from('complaints')
          .select()
          .eq('tenant_id', _tenantId!)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _errorMessage = 'Gagal mengambil keluhan: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Get tenant payments
  Future<List<Map<String, dynamic>>> getTenantPayments() async {
    if (_tenantId == null) return [];

    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('tenant_id', _tenantId!)
          .order('due_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _errorMessage = 'Gagal mengambil pembayaran: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  // Submit complaint
  Future<bool> submitComplaint({
    required String title,
    required String description,
    required String category,
    String? imageUrl,
  }) async {
    if (_tenantId == null || _roomId == null) {
      _errorMessage = 'Tenant tidak terautentikasi';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('complaints').insert({
        'tenant_id': _tenantId,
        'room_id': _roomId,
        'title': title,
        'description': description,
        'category': category,
        'status': 'pending',
        'image_url': imageUrl,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal membuat keluhan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}