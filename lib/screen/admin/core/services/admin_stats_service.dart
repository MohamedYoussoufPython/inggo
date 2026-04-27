import 'package:supabase_flutter/supabase_flutter.dart';

class AdminStatsService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthStart = DateTime(now.year, now.month, 1);

      final totalRidesData = await _client
          .from('rides')
          .select('id')
          .neq('status', 'cancelled');
      
      final activeDriversData = await _client
          .from('drivers')
          .select('id')
          .eq('status', 'active');

      final pendingDriversData = await _client
          .from('drivers')
          .select('id')
          .eq('status', 'pending');

      final totalUsersData = await _client
          .from('profiles')
          .select('id')
          .eq('role', 'client');

      final weeklyRidesData = await _client
          .from('rides')
          .select('id')
          .gte('created_at', weekAgo.toIso8601String())
          .neq('status', 'cancelled');

      final monthlyRevenueData = await _client
          .from('rides')
          .select('price')
          .gte('created_at', monthStart.toIso8601String())
          .eq('status', 'completed');

      int revenue = 0;
      for (var r in monthlyRevenueData) {
        revenue += (r['price'] as int?) ?? 0;
      }

      return {
        'totalRides': totalRidesData.length,
        'activeDrivers': activeDriversData.length,
        'pendingDrivers': pendingDriversData.length,
        'totalUsers': totalUsersData.length,
        'weeklyRides': weeklyRidesData.length,
        'revenue': revenue,
      };
    } catch (e) {
      return {
        'totalRides': 0,
        'activeDrivers': 0,
        'pendingDrivers': 0,
        'totalUsers': 0,
        'weeklyRides': 0,
        'revenue': 0,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentRides({int limit = 10}) async {
    try {
      final response = await _client
          .from('rides')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingDrivers({int limit = 5}) async {
    try {
      final response = await _client
          .from('drivers')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getFinanceStats() async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0);

      final currentMonthRides = await _client
          .from('rides')
          .select('price')
          .gte('created_at', monthStart.toIso8601String())
          .eq('status', 'completed');

      final lastMonthRides = await _client
          .from('rides')
          .select('price')
          .gte('created_at', lastMonthStart.toIso8601String())
          .lte('created_at', lastMonthEnd.toIso8601String())
          .eq('status', 'completed');

      int currentRevenue = 0;
      for (var r in currentMonthRides) {
        currentRevenue += (r['price'] as int?) ?? 0;
      }

      int lastRevenue = 0;
      for (var r in lastMonthRides) {
        lastRevenue += (r['price'] as int?) ?? 0;
      }

      return {
        'currentRevenue': currentRevenue,
        'lastRevenue': lastRevenue,
        'rideCount': currentMonthRides.length,
        'avgPerRide': currentMonthRides.isNotEmpty 
            ? (currentRevenue / currentMonthRides.length).round() 
            : 0,
      };
    } catch (e) {
      return {
        'currentRevenue': 0,
        'lastRevenue': 0,
        'rideCount': 0,
        'avgPerRide': 0,
      };
    }
  }
}