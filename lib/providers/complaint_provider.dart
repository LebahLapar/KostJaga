import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ComplaintProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingComplaints => _complaints.where((c) => c.status == 'pending').length;
  int get inProgressComplaints => _complaints.where((c) => c.status == 'in_progress').length;
  int get resolvedComplaints => _complaints.where((c) => c.status == 'resolved').length;

  Future<void> fetchComplaints() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('complaints')
          .select()
          .order('created_at', ascending: false);

      _complaints = (response as List).map((json) => Complaint.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addComplaint(Complaint complaint) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('complaints').insert(complaint.toJson());
      await fetchComplaints();

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

  Future<bool> updateComplaint(String id, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('complaints').update(updates).eq('id', id);
      await fetchComplaints();

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

  Future<bool> resolveComplaint(String id) async {
    return updateComplaint(id, {
      'status': 'resolved',
      'resolved_at': DateTime.now().toIso8601String(),
    });
  }

  List<Complaint> getComplaintsByRoomId(String roomId) {
    return _complaints.where((c) => c.roomId == roomId).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}