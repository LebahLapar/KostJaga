import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class TenantProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Tenant> _tenants = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Tenant> get tenants => _tenants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get activeTenants => _tenants.where((t) => t.status == 'active').length;

  Future<void> fetchTenants() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('tenants')
          .select()
          .order('name', ascending: true);

      _tenants = (response as List).map((json) => Tenant.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTenant(Tenant tenant) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('tenants').insert(tenant.toJson());
      
      // Update room status to occupied
      await _supabase
          .from('rooms')
          .update({'status': 'occupied'})
          .eq('id', tenant.roomId);

      await fetchTenants();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTenant(String id, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('tenants').update(updates).eq('id', id);
      await fetchTenants();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTenant(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('tenants').delete().eq('id', id);
      await fetchTenants();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<Tenant> getTenantsByRoomId(String roomId) {
    return _tenants.where((t) => t.roomId == roomId && t.status == 'active').toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}