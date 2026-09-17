import 'package:flutter/material.dart';
import 'package:mozo/presentation/components/ui/app_widgets.dart';
import 'package:mozo/constants/colors.dart';
import 'package:mozo/models/notification.dart';
import 'package:mozo/presentation/components/notification_item.dart';
import 'package:mozo/providers/in_app_notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
        Provider.of<InAppNotificationProvider>(context);
    final List<NotificationModel> notifications =
        notificationProvider.getNotifications();

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      body: SafeArea(
        child: notifications.isEmpty
            ? const Column(
                children: [
                  PageHeader(title: 'Notifications', showBack: true),
                  Expanded(
                    child: EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'No new notifications',
                      subtitle: 'News about our latest releases will show up here.',
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: notifications.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const PageHeader(title: 'Notifications', showBack: true);
                  }
                  return NotificationItem(
                    notification: notifications[index - 1],
                  );
                },
              ),
      ),
    );
  }
}
