import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chill/constants/colors.dart';
import 'package:chill/platform_utils.dart';
import 'package:chill/services/notification_service.dart';
import 'package:chill/services/preferences_service.dart';
import 'package:provider/provider.dart';
import 'package:chill/providers/authentication_provider.dart';

class NotificationPermissionModal extends StatelessWidget {
  const NotificationPermissionModal({super.key});

  static Future<void> showIfNeeded(BuildContext? context) async {
    // Skip on web platform
    if (PlatformUtils.isWeb) {
      return;
    }

    // Validate context is provided and mounted
    if (context == null || !context.mounted) {
      return;
    }

    // Check if user is logged in
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final user = authProvider.getUser();
    if (user == null) {
      return;
    }

    // Check if notification permission is already granted
    final notificationService = NotificationService();
    final isGranted = await notificationService.isNotificationPermissionGranted();
    
    // Also check our stored preference (in case permission was granted previously)
    final storedGranted = await PreferencesService.isNotificationPermissionGranted();
    
    if (isGranted || storedGranted) {
      // Permission already granted; still sync FCM token to backend (e.g. after token refresh or reinstall)
      await NotificationService().reportFcmTokenToBackend(user);
      return;
    }

    // Validate context one more time before showing dialog
    if (!context.mounted) {
      return;
    }

    // Show the modal (will show on every app open until permission is granted)
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NotificationPermissionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.colorBackground.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.colorPrimary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notification Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.colorPrimary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: AppColors.colorPrimary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  "Stay Updated!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                const Text(
                  "Enable notifications to get updates about new releases, exclusive content, and special offers.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // Don't mark as granted - modal will show again next time
                          // User can dismiss it, but it will keep appearing until they accept
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Not Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Get user from provider
                          final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
                          final user = authProvider.getUser();
                          
                          // Request notification permission
                          await NotificationService().requestNotificationPermission(user);
                          
                          // Check if permission was actually granted
                          final notificationService = NotificationService();
                          final isGranted = await notificationService.isNotificationPermissionGranted();
                          
                          // Mark permission as granted if it was actually granted
                          await PreferencesService.setNotificationPermissionGranted(isGranted);
                          
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.colorPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Enable",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
