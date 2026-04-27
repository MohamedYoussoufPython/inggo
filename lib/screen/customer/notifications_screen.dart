import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/inggo_theme.dart';
import '../../core/providers/notifications_provider.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _activeFilter = 'all';

  static const _filters = [
    {'key': 'all', 'label': 'Toutes'},
    {'key': 'course', 'label': 'Courses'},
    {'key': 'promo', 'label': 'Promotions'},
    {'key': 'system', 'label': 'Système'},
  ];

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    final notifications = notificationsAsync.valueOrNull ?? [];

    final filtered = _activeFilter == 'all'
        ? notifications
        : notifications.where((n) => n.type == _activeFilter).toList();

    final todayItems = filtered.where((n) => n.dateGroup == 'today').toList();
    final yesterdayItems =
        filtered.where((n) => n.dateGroup == 'yesterday').toList();

    return Scaffold(
      backgroundColor: InggoColors.surface,
      body: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 15,
              left: 24,
              right: 24,
              bottom: 20,
            ),
            color: InggoColors.surface,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: Color(0xFF121212)),
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  'Notifications',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF121212),
                      fontFamily: 'Roboto'),
                ),
              ],
            ),
          ),

          // FILTER TABS
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final f = _filters[index];
                final isActive = _activeFilter == f['key'];
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = f['key']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFFC107)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f['label']!,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color:
                              isActive ? InggoColors.text1 : InggoColors.text3,
                          fontFamily: 'Roboto'),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // NOTIFICATION LIST
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (_) => filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        if (todayItems.isNotEmpty) ...[
                          _buildDateDivider("Aujourd'hui"),
                          ...todayItems.map(_buildNotifItem),
                        ],
                        if (yesterdayItems.isNotEmpty) ...[
                          _buildDateDivider('Hier'),
                          ...yesterdayItems.map(_buildNotifItem),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: InggoColors.border1),
          SizedBox(height: 16),
          Text('Aucune notification',
              style: TextStyle(
                  fontSize: 15,
                  color: InggoColors.text3,
                  fontFamily: 'Roboto')),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      color: const Color(0xFFFAFAFA),
      child: Text(label.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFFBBBBBB),
              letterSpacing: 1,
              fontFamily: 'Roboto')),
    );
  }

  Widget _buildNotifItem(NotificationModel notif) {
    return GestureDetector(
      onTap: () => _openMessage(notif),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color:
              notif.isUnread ? InggoColors.primaryLight : InggoColors.surface,
          border: const Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          children: [
            if (notif.isUnread)
              Container(
                width: 4,
                height: 54,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: notif.iconBgColor,
                borderRadius: BorderRadius.circular(16),
                border: notif.type == 'course'
                    ? Border.all(
                        color: const Color(0xFFFFC107).withAlpha(77), width: 2)
                    : null,
                boxShadow: notif.type == 'course'
                    ? [
                        BoxShadow(
                            color: const Color(0xFFFFC107).withAlpha(26),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : null,
              ),
              child: Icon(notif.icon, size: 28, color: notif.iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF121212),
                              fontFamily: 'Roboto'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notif.time,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFBBBBBB),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        height: 1.4,
                        fontFamily: 'Roboto'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMessage(NotificationModel notif) {
    ref.read(notificationsProvider.notifier).markAsRead(notif.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => _NotificationDetailSheet(notif: notif),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  final NotificationModel notif;
  const _NotificationDetailSheet({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: InggoColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 20, bottom: 25),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2)))),
          Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20)),
              child:
                  Icon(notif.icon, size: 44, color: const Color(0xFFFFC107))),
          const SizedBox(height: 20),
          Text(notif.title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF121212),
                  fontFamily: 'Roboto')),
          const SizedBox(height: 10),
          Text(notif.time,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFBBBBBB),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Roboto')),
          const SizedBox(height: 24),
          Text(notif.description,
              style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                  height: 1.6,
                  fontFamily: 'Roboto')),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFFFC107).withAlpha(77),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Center(
                  child: Text("J'ai compris",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: InggoColors.text1,
                          fontFamily: 'Roboto'))),
            ),
          ),
        ],
      ),
    );
  }
}
