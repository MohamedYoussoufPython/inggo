import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/driver_model.dart';
import 'user_provider.dart';

class DriverNotifier extends StateNotifier<AsyncValue<DriverModel?>> {
  final Ref ref;

  DriverNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchDriver();
  }

  Future<void> fetchDriver() async {
    state = const AsyncValue.loading();
    try {
      final supabase = ref.read(supabaseProvider);
      final user = supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final data = await supabase
          .from('drivers')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        state = const AsyncValue.data(null);
        return;
      }

      state = AsyncValue.data(DriverModel.fromJson(data));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleOnline() async {
    final driverValue = state.value;
    if (driverValue == null) return;
    
    final newStatus = !driverValue.isOnline;
    
    try {
      final supabase = ref.read(supabaseProvider);
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      await supabase
          .from('drivers')
          .update({'is_online': newStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);
          
      state = AsyncValue.data(DriverModel(
        id: driverValue.id,
        fullName: driverValue.fullName,
        phone: driverValue.phone,
        email: driverValue.email,
        address: driverValue.address,
        vehicle: driverValue.vehicle,
        licensePlate: driverValue.licensePlate,
        status: driverValue.status,
        isOnline: newStatus,
        rating: driverValue.rating,
        totalRides: driverValue.totalRides,
        avatarUrl: driverValue.avatarUrl,
        bankName: driverValue.bankName,
        bankNumber: driverValue.bankNumber,
      ));
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> updateVehicleInfo(String vehicle, String licensePlate) async {
    final driverValue = state.value;
    if (driverValue == null) return;

    try {
      final supabase = ref.read(supabaseProvider);
      final user = supabase.auth.currentUser;
      if (user == null) return;
      
      await supabase
          .from('drivers')
          .update({
            'vehicle': vehicle,
            'license_plate': licensePlate,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', user.id);
          
      await fetchDriver();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateBankingInfo(String bankName, String bankNumber) async {
    final driverValue = state.value;
    if (driverValue == null) return;

    try {
      final supabase = ref.read(supabaseProvider);
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase
          .from('drivers')
          .update({
            'bank_name': bankName,
            'bank_number': bankNumber,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', user.id);

      await fetchDriver();
    } catch (e) {
      // Handle error
    }
  }
}

final driverProvider = StateNotifierProvider<DriverNotifier, AsyncValue<DriverModel?>>((ref) {
  return DriverNotifier(ref);
});

final driverIsOnlineProvider = Provider<bool>((ref) {
  final driverAsync = ref.watch(driverProvider);
  return driverAsync.value?.isOnline ?? false;
});
