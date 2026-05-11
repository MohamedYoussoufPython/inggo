import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';
import '../model/notification_model.dart';

class NotificationState {
  final bool isLoading;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String? error;

  const NotificationState({
    this.isLoading = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.error,
  });

  NotificationState copyWith({
    bool? isLoading,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? error,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      final data = await SupabaseService.instance.getAll(
        'notifications',
        query: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
        limit: 50,
      );

      final notifs = data.map((e) => NotificationModel.fromJson(e)).toList();
      final unread = notifs.where((n) => !n.isRead).length;
      state = state.copyWith(
        isLoading: false,
        notifications: notifs,
        unreadCount: unread,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await SupabaseService.instance.update(
        'notifications',
        notificationId,
        {'is_read': true},
      );
      final updated = state.notifications.map((n) {
        if (n.id == notificationId) return n.copyWith(isRead: true);
        return n;
      }).toList();
      final unread = updated.where((n) => !n.isRead).length;
      state = state.copyWith(notifications: updated, unreadCount: unread);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Add an incoming notification received via Realtime.
  /// Prepends it to the list and increments unread count.
  void addIncomingNotification(NotificationModel notif) {
    final updated = [notif, ...state.notifications];
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = SupabaseService.instance.currentUserId;
      if (userId == null) return;

      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      final updated =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(notifications: updated, unreadCount: 0);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
