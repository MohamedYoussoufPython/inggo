import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../../widget/widgets.dart';
import '../../provider/notification_provider.dart';
import '../../l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(notificationProvider.notifier).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: InggoAppBar(
        title: loc.notifications,
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(notificationProvider.notifier).markAllAsRead(),
              child: Text(loc.markAllReadShort,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
            ),
        ],
      ),
      body: notifState.isLoading
          ? const InggoLoading()
          : notifState.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 64.w, color: AppColors.textHint),
                      SizedBox(height: 16.h),
                      Text(loc.noNotifications, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: notifState.notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifState.notifications[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: InggoCard(
                        color: n.isRead ? null : AppColors.primary.withValues(alpha: 0.05),
                        onTap: () => ref.read(notificationProvider.notifier).markAsRead(n.id),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 2.h),
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: n.isRead ? Colors.transparent : AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title, style: AppTextStyles.labelMedium),
                                  SizedBox(height: 4.h),
                                  Text(n.body, style: AppTextStyles.bodySmall),
                                  if (n.createdAt != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(Formatters.formatDateTime(n.createdAt!), style: AppTextStyles.bodySmall),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
