import 'package:flutter/material.dart';
import 'package:volt/constants/app_theme.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/models/notification.dart';
import 'package:volt/presentation/components/notification_item.dart';
import 'package:volt/providers/in_app_notification_provider.dart';
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
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          size: 40,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Text('Notifications', style: AppTextStyles.displayTitle.copyWith(fontSize: 28)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const EnergyTrail(height: 1.4),
                  ],
                ),
              ),
              Expanded(
                child: notifications.isEmpty
                    ? const EmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: 'No new signals',
                        subtitle: 'News about our latest releases will show up here.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return NotificationItem(
                            notification: notifications[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
