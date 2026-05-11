import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_service.dart';
import '../../provider/notification_provider.dart';
import '../../model/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  static final _log = Logger();

  RealtimeChannel? _channel;
  ProviderContainer? _container;

  /// Set the Riverpod provider container so the service can update
  /// the notification provider when a new notification arrives via Realtime.
  void setContainer(ProviderContainer container) {
    _container = container;
  }

  void startListening(String userId) {
    _log.i('Starting notifications for $userId');
    _channel = SupabaseService.instance.subscribeToTable(
      'notifications',
      filterColumn: 'user_id',
      filterValue: userId,
      onChange: (payload) {
        _log.i('Notification: ${payload.eventType}');

        // When a new notification is inserted, update the provider
        if (payload.eventType == PostgresChangeEvent.insert) {
          final notif = NotificationModel.fromJson(payload.newRecord);
          _log.i('New notification: ${notif.title}');

          // Update the notification provider to show the new notification
          if (_container != null) {
            final notifier = _container!.read(notificationProvider.notifier);
            notifier.addIncomingNotification(notif);
          }
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
