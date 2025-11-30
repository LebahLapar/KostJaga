import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class KostProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<KostRoom> _rooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<KostRoom> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get availableRooms => _rooms.where((r) => r.status == 'available').length;
  int get occupiedRooms => _rooms.where((r) => r.status == 'occupied').length;
  int get maintenanceRooms => _rooms.where((r) => r.status == 'maintenance').length;

  Future<void> fetchRooms() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('rooms')
          .select()
          .order('room_number', ascending: true);

      _rooms = (response as List)
          .map((json) => KostRoom.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRoom(KostRoom room) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('rooms').insert(room.toJson());
      await fetchRooms();

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

  Future<bool> updateRoom(String id, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase
          .from('rooms')
          .update(updates)
          .eq('id', id);

      await fetchRooms();

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

  Future<bool> deleteRoom(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('rooms').delete().eq('id', id);
      await fetchRooms();

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

  KostRoom? getRoomById(String id) {
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}