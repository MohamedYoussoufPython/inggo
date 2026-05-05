import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'supabase_service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  static final _log = Logger();

  RealtimeChannel? _channel;

  void startListening(String userId) {
    _log.i('Starting notifications for $userId');
    _channel = SupabaseService.instance.subscribeToTable(
      'notifications',
      filterColumn: 'user_id',
      filterValue: userId,
      onChange: (payload) {
        _log.i('Notification: ${payload.eventType}');
      },
    );
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    await SupabaseService.instance.insert('notifications', {
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
    });
    _log.i('Notification sent to $userId');
  }

  Future<void> markAsRead(String notificationId) async {
    await SupabaseService.instance.update(
      'notifications',
      notificationId,
      {'is_read': true},
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final supabase = SupabaseService.client;
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  void stopListening() {
    if (_channel != null) {
      SupabaseService.instance.unsubscribe(_channel!);
      _channel = null;
    }
  }
}
