import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supabase_models.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class SupabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // --- Authentication ---

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<AuthResponse> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
    } catch (e) {
      throw Exception('Erro ao cadastrar: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Erro ao enviar email de recuperação: $e');
    }
  }

  // --- Data Fetching ---

  Future<Profile?> getProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  Future<List<TransactionModel>> getRecentTransactions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(5);

      return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  Future<UserStreak?> getUserStreak() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await _client
          .from('user_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return UserStreak(currentStreak: 0, longestStreak: 0);

      return UserStreak.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching streak: $e');
      return null;
    }
  }

  Future<Map<String, double>> getFinancialSummary() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null)
        return {'balance': 0.0, 'income': 0.0, 'expense': 0.0};

      // This is a simplified calculation. Ideally, use Supabase RPC or aggregate queries.
      final transactions = await _client
          .from('transactions')
          .select('amount, type')
          .eq('user_id', userId);

      double income = 0.0;
      double expense = 0.0;

      for (var t in transactions) {
        final amount = (t['amount'] as num).toDouble();
        if (t['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      return {
        'balance': income - expense,
        'income': income,
        'expense': expense,
      };
    } catch (e) {
      debugPrint('Error fetching summary: $e');
      return {'balance': 0.0, 'income': 0.0, 'expense': 0.0};
    }
  }

  // --- Savings & Education ---

  Future<List<SavingsGoal>> getSavingsGoals() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('savings_goals')
          .select()
          .eq('user_id', userId);

      return (data as List).map((e) => SavingsGoal.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching savings goals: $e');
      return [];
    }
  }

  Future<void> addSavingsGoal({
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime? deadline,
    required String icon,
    required String color,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client.from('savings_goals').insert({
        'user_id': userId,
        'title': title,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'deadline': deadline?.toIso8601String(),
        'icon': icon,
        'color': color,
      });
    } catch (e) {
      throw Exception('Erro ao adicionar meta: $e');
    }
  }

  Future<void> deleteSavingsGoal(String id) async {
    try {
      await _client.from('savings_goals').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar meta: $e');
    }
  }

  Future<void> updateSavingsGoal({
    required String id,
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime? deadline,
    required String icon,
    required String color,
  }) async {
    try {
      await _client
          .from('savings_goals')
          .update({
            'title': title,
            'target_amount': targetAmount,
            'current_amount': currentAmount,
            'deadline': deadline?.toIso8601String(),
            'icon': icon,
            'color': color,
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao atualizar meta: $e');
    }
  }

  Future<List<Lesson>> getLessons() async {
    try {
      final data = await _client
          .from('lessons')
          .select()
          .eq('is_published', true)
          .order('id', ascending: true);

      return (data as List).map((e) => Lesson.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      return [];
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client.from('transactions').insert({
        'user_id': userId,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar transação: $e');
    }
  }
}
