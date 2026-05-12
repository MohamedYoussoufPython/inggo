import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'supabase_service.dart';
import '../../model/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  static final _log = Logger();

  RealtimeChannel? _channel;

  /// Callback invoked when a new notification arrives via Realtime.
  /// Set from the widget layer (InggoApp) so the service can update
  /// the notification provider without depending on ProviderContainer.
  void Function(NotificationModel)? _onNotificationCallback;

  /// Set the callback that will be called when a new notification arrives.
  void setOnNotificationCallback(void Function(NotificationModel) callback) {
    _onNotificationCallback = callback;
  }

  void startListening(String userId) {
    _log.i('Starting notifications for $userId');
    _channel = SupabaseService.instance.subscribeToTable(
      'notifications',
      filterColumn: 'user_id',
      filterValue: userId,
      onChange: (payload) {
        _log.i('Notification: ${payload.eventType}');

        // When a new notification is inserted, forward it via callback
        if (payload.eventType == PostgresChangeEvent.insert) {
          final notif = NotificationModel.fromJson(payload.newRecord);
          _log.i('New notification: ${notif.title}');
          _onNotificationCallback?.call(notif);
        }
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
