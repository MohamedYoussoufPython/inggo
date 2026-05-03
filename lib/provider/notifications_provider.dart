import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/notification_model.dart';
import 'user_provider.dart';

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final SupabaseClient _supabase;

  NotificationsNotifier(this._supabase) : super(const AsyncValue.loading()) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('occurred_at', ascending: false);

      final notifications =
          data.map((e) => NotificationModel.fromMap(e)).toList();

      // Grouper par dateGroup
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final withDateGroup = notifications.map((n) {
        final notifDate =
            DateTime(n.occurredAt.year, n.occurredAt.month, n.occurredAt.day);
        String group = 'older';
        if (notifDate == today) {
          group = 'today';
        } else if (notifDate == yesterday) {
          group = 'yesterday';
        }
        return NotificationModel(
          id: n.id,
          title: n.title,
          description: n.description,
          occurredAt: n.occurredAt,
          dateGroup: group,
          type: n.type,
          icon: n.icon,
          iconBgColor: n.iconBgColor,
          iconColor: n.iconColor,
          isUnread: n.isUnread,
        );
      }).toList();

      state = AsyncValue.data(withDateGroup);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(int id) async {
    await _supabase
        .from('notifications')
        .update({'is_unread': false}).eq('id', id);
    state = state.whenData((notifs) => [
          for (final n in notifs)
            if (n.id == id) n.copyWith(isUnread: false) else n
        ]);
  }

  int get unreadCount {
    return state.valueOrNull?.where((n) => n.isUnread).length ?? 0;
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationsNotifier(ref.watch(supabaseProvider));
});

final unreadCountProvider = Provider<int>((ref) {
  return ref
          .watch(notificationsProvider)
          .valueOrNull
          ?.where((n) => n.isUnread)
          .length ??
      0;
});
