import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final String title;
  final String description;
  final DateTime occurredAt;
  final String dateGroup;
  final String type;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isUnread;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.occurredAt,
    required this.dateGroup,
    required this.type,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isUnread = false,
  });

  // Constructeur depuis Supabase
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: (map['id'] as num).toInt(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      occurredAt: DateTime.parse(
          map['occurred_at'] ?? DateTime.now().toIso8601String()),
      dateGroup: map['date_group'] ?? 'today',
      type: map['type'] ?? 'system',
      icon: _parseIcon(map['icon']),
      iconBgColor: _parseColor(map['icon_bg_color']),
      iconColor: _parseColor(map['icon_color']),
      isUnread: map['is_unread'] ?? false,
    );
  }

  static IconData _parseIcon(String? iconName) {
    switch (iconName) {
      case 'two_wheeler':
        return Icons.two_wheeler;
      case 'local_offer':
        return Icons.local_offer;
      case 'verified_user':
        return Icons.verified_user;
      case 'check_circle':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  static Color _parseColor(String? hex) {
    if (hex == null) return const Color(0xFFFFF3E0);
    try {
      final colorInt = int.parse(hex.replaceFirst('#', '0xFF'));
      return Color(colorInt);
    } catch (_) {
      return const Color(0xFFFFF3E0);
    }
  }

  // Getter pour afficher l'heure formatée
  String get time {
    return '${occurredAt.hour.toString().padLeft(2, '0')}:${occurredAt.minute.toString().padLeft(2, '0')}';
  }

  NotificationModel copyWith({bool? isUnread}) {
    return NotificationModel(
      id: id,
      title: title,
      description: description,
      occurredAt: occurredAt,
      dateGroup: dateGroup,
      type: type,
      icon: icon,
      iconBgColor: iconBgColor,
      iconColor: iconColor,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
