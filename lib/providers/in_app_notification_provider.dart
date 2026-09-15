import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chill/models/notification.dart';
import 'package:chill/models/user/user.dart';
import 'package:chill/network/api_paths.dart';
import 'package:chill/services/authentication_service.dart';
import 'package:chill/services/media_service.dart';
import 'package:chill/services/network_service.dart';

typedef OnSuccessCallback = void Function(User user);
typedef OnFailureCallback = void Function(dynamic error);

class InAppNotificationProvider extends ChangeNotifier {
  AuthenticationService authenticationService = AuthenticationService();
  List<NotificationModel> _notifications = [];

  Future<void> init() async {
    await NetworkService().get(APIPath.inAppNotifications, (data) {
      final mediaService = MediaService.instance;

      final items = (data['body']['data'] as List)
          .map((item) => NotificationModel.fromMap(item))
          .toList();
      for (var item in items) {
        if (item.type == NotificationType.newRelease) {
          item.baseItem = mediaService.getMediaById(item.baseItemId!, null);
        }
      }
      _notifications = items;
      notifyListeners();
    }, (error) {
      // Handle error if needed
    }, () {}, maxRetries: 100);
  }

  List<NotificationModel> getNotifications() {
    return _notifications;
  }
}
