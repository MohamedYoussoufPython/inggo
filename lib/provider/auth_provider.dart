import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/supabase_service.dart';
import '../core/router/app_router.dart';
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
        // Cache the role for the router's role-based access control
        AppRouter.setCachedRole(user.role.name);
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

  /// Update user data in state (called after profile edit)
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  /// Refresh auth state after a successful login.
  /// Called from LoginScreen to sync AuthProvider with the new session.
  Future<void> refreshAfterLogin() async {
    try {
      final session = SupabaseService.instance.currentSession;
      if (session == null) return;

      final userData = await SupabaseService.instance.getById(
        'profiles',
        session.user.id,
      );
      final user = UserModel.fromJson(userData);

      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString('language') ?? 'fr';

      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        locale: Locale(langCode),
      );
    } catch (e) {
      // Even if profile fetch fails, still mark as authenticated
      // so the app can function. The profile will be loaded later.
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<void> signOut() async {
    await SupabaseService.instance.signOut();
    AppRouter.clearCachedRole();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
