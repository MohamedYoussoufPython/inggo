import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../core/services/supabase_service.dart';

/// Tracks the driver's verification status via Realtime.
/// This provider lives at the app level (not tied to a screen),
/// so the subscription survives navigation away from
/// PendingVerificationScreen.
class VerificationState {
  final bool isVerified;
  final bool isListening;

  const VerificationState({
    this.isVerified = false,
    this.isListening = false,
  });

  VerificationState copyWith({
    bool? isVerified,
    bool? isListening,
  }) {
    return VerificationState(
      isVerified: isVerified ?? this.isVerified,
      isListening: isListening ?? this.isListening,
    );
  }
}

class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier() : super(const VerificationState());

  static final _log = Logger();
  RealtimeChannel? _channel;

  /// Start listening for verification status changes on the drivers table.
  /// Call this when a driver logs in and is NOT yet verified.
  void startListening() {
    if (state.isListening) return; // Already listening

    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) return;

    _log.i('Starting verification listener for driver $userId');

    _channel = SupabaseService.instance.subscribeToTable(
      'drivers',
      filterColumn: 'id',
      filterValue: userId,
      onChange: (payload) {
        final isVerified = payload.newRecord['is_verified'] as bool?;
        _log.i('Verification update: isVerified=$isVerified');
        if (isVerified == true) {
          state = state.copyWith(isVerified: true);
        }
      },
    );

    state = state.copyWith(isListening: true);
  }

  /// Stop listening (e.g., when the driver is verified and navigated away,
  /// or when the user signs out).
  void stopListening() {
    if (_channel != null) {
      SupabaseService.instance.unsubscribe(_channel!);
      _channel = null;
      _log.i('Verification listener stopped');
    }
    state = const VerificationState();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

final verificationProvider =
    StateNotifierProvider<VerificationNotifier, VerificationState>((ref) {
  return VerificationNotifier();
});
