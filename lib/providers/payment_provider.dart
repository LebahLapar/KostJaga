import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class PaymentProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingPayments => _payments.where((p) => p.status == 'pending').length;
  int get overduePayments => _payments.where((p) => p.status == 'overdue').length;
  int get paidPayments => _payments.where((p) => p.status == 'paid').length;

  double get totalRevenue {
    return _payments
        .where((p) => p.status == 'paid')
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  Future<void> fetchPayments() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('payments')
          .select()
          .order('due_date', ascending: false);

      _payments = (response as List).map((json) => Payment.fromJson(json)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPayment(Payment payment) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('payments').insert(payment.toJson());
      await fetchPayments();

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

  Future<bool> updatePayment(String id, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('payments').update(updates).eq('id', id);
      await fetchPayments();

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

  Future<bool> markAsPaid(String id, String? proofUrl) async {
    return updatePayment(id, {
      'status': 'paid',
      'paid_date': DateTime.now().toIso8601String(),
      'proof_image_url': proofUrl,
    });
  }

  List<Payment> getPaymentsByTenantId(String tenantId) {
    return _payments.where((p) => p.tenantId == tenantId).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}