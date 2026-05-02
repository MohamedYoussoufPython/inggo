import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/drivers/data/models/driver_model.dart';

class DriverService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<List<DriverModel>> getAllDrivers() async {
    try {
      final response = await _client
          .from('drivers')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((e) => DriverModel.fromMap(e)).toList();
    } catch (e) {
      // Return mock data if table doesn't exist yet
      return _getMockDrivers();
    }
  }

  static Future<DriverModel?> getDriverById(String id) async {
    try {
      final response =
          await _client.from('drivers').select().eq('id', id).maybeSingle();

      if (response != null) {
        return DriverModel.fromMap(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> createDriver({
    required String name,
    required String phone,
    String? email,
    String? address,
    required String vehicle,
    required String plate,
  }) async {
    try {
      await _client.from('drivers').insert({
        'full_name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'vehicle': vehicle,
        'license_plate': plate,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingDrivers() async {
    try {
      final response = await _client
          .from('profiles')
          .select('*, driver_documents(*)')
          .eq('role', 'driver')
          .eq('status', 'pending');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<void> approveDriver({
    required String userId,
    required String name,
    required String phone,
    required String vehicle,
    required String plate,
  }) async {
    try {
      // 1. Insert into drivers table
      await _client.from('drivers').insert({
        'id': userId,
        'full_name': name,
        'phone': phone,
        'vehicle': vehicle,
        'license_plate': plate,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. Update profile status to approved
      await _client
          .from('profiles')
          .update({'status': 'approved'}).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> rejectDriver(String userId) async {
    try {
      await _client
          .from('profiles')
          .update({'status': 'rejected'}).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateDriverStatus(String id, String status) async {
    try {
      // Update drivers table
      await _client.from('drivers').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // Also update profiles table for consistency
      String profileStatus = 'approved';
      if (status == 'suspended') profileStatus = 'suspended';
      if (status == 'pending') profileStatus = 'pending';

      await _client
          .from('profiles')
          .update({'status': profileStatus}).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateDriver(String id, Map<String, dynamic> data) async {
    try {
      await _client.from('drivers').update(data).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteDriver(String id) async {
    try {
      await _client.from('drivers').delete().eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static List<DriverModel> _getMockDrivers() {
    return [
      DriverModel(
          id: '101',
          name: 'Khaireh Abdi Bogoreh',
          phone: '77 85 43 21',
          email: 'khaireh@gmail.com',
          address: 'Balbala T4, Av. Cheik',
          vehicle: 'Yamaha FZ',
          plate: '336D91',
          status: 'pending'),
      DriverModel(
          id: '102',
          name: 'Ibrahim Youssouf Ali',
          phone: '77 11 22 33',
          email: 'ibra@hotmail.com',
          address: 'Cité Hodan 2',
          vehicle: 'TVS Apache',
          plate: '123A45',
          status: 'active'),
      DriverModel(
          id: '103',
          name: 'Farah Ali Waiss',
          phone: '77 99 88 77',
          email: 'farah@yahoo.fr',
          address: 'PK12, Cité Nassib',
          vehicle: 'Bajaj Boxer',
          plate: '999X88',
          status: 'pending'),
      DriverModel(
          id: '104',
          name: 'Said Houssein Robleh',
          phone: '77 55 66 44',
          email: 'said@gmail.com',
          address: 'Quartier 4, Rue 12',
          vehicle: 'Yamaha YBR',
          plate: '444B22',
          status: 'suspended'),
      DriverModel(
          id: '105',
          name: 'Amina Mohamed Daher',
          phone: '77 44 55 66',
          email: 'amina@gmail.com',
          address: 'Héron, Rue de la Paix',
          vehicle: 'Honda Ace',
          plate: '777C11',
          status: 'pending'),
    ];
  }
}
