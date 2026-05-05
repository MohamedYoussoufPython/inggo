import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/supabase_service.dart';
import '../model/user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final Locale locale;
  final bool isOnboarded;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.locale = const Locale('fr'),
    this.isOnboarded = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
    Locale? locale,
    bool? isOnboarded,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      locale: locale ?? this.locale,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString('language') ?? 'fr';
      final onboarded = prefs.getBool('onboarded') ?? false;

      final session = SupabaseService.instance.currentSession;
      if (session != null) {
        final userData = await SupabaseService.instance.getById(
          'profiles',
          session.user.id,
        );
        final user = UserModel.fromJson(userData);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          locale: Locale(langCode),
          isOnboarded: onboarded,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          locale: Locale(langCode),
          isOnboarded: onboarded,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fullPhone = '+253${phone.replaceAll(RegExp(r'[^\d]'), '')}';
      await SupabaseService.instance.signInWithOtp(fullPhone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fullPhone = '+253${phone.replaceAll(RegExp(r'[^\d]'), '')}';
      await SupabaseService.instance.verifyOtp(fullPhone, otp);

      final userId = SupabaseService.instance.currentUserId;
      if (userId != null) {
        final userData =
            await SupabaseService.instance.getById('profiles', userId);
        final user = UserModel.fromJson(userData);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> registerClient(String fullName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('Non authentifié');

      final phone = SupabaseService.instance.currentUser?.phone ?? '';
      await SupabaseService.instance.insert('profiles', {
        'id': userId,
        'full_name': fullName,
        'phone': phone,
        'role': 'client',
        'language': state.locale.languageCode,
      });

      final userData =
          await SupabaseService.instance.getById('profiles', userId);
      final user = UserModel.fromJson(userData);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> registerDriver({
    required String fullName,
    required String plateNumber,
    String? vehicleColor,
    String? idCardUrl,
    String? licenseUrl,
    String? vehiclePhotoUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) throw Exception('Non authentifié');

      final phone = SupabaseService.instance.currentUser?.phone ?? '';

      await SupabaseService.instance.insert('profiles', {
        'id': userId,
        'full_name': fullName,
        'phone': phone,
        'role': 'driver',
        'language': state.locale.languageCode,
      });

      await SupabaseService.instance.insert('drivers', {
        'id': userId,
        'plate_number': plateNumber,
        'vehicle_color': vehicleColor,
        'vehicle_type': 'moto',
        'is_verified': false,
        'id_card_url': idCardUrl,
        'license_url': licenseUrl,
        'vehicle_photo_url': vehiclePhotoUrl,
      });

      final userData =
          await SupabaseService.instance.getById('profiles', userId);
      final user = UserModel.fromJson(userData);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    state = state.copyWith(locale: Locale(code));
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarded', true);
    state = state.copyWith(isOnboarded: true);
  }

  Future<void> signOut() async {
    await SupabaseService.instance.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
