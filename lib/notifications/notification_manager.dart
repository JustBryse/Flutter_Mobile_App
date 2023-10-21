// manages app-wide notification information
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cao_prototype/firebase/firebase_api.dart';
import 'package:cao_prototype/notifications/models/friend_request_response_notification.dart';
import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/notifications/notification_database.dart';
import 'package:cao_prototype/pages/components/component_pages/notification_components/unactionable_notification_widget.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:path_provider/path_provider.dart';

abstract class NotificationManager {
  static String _backgroundNotificationFileName = "backgroundNotifications.txt";

  static bool friendRequestNotificationIconEnabled = false;
  static bool associationInvitationNotificationIconEnabled = false;

  // stores all the current unactionable notification widgets that should be visible in the notification menu
  static List<UnactionableNotification> unactionableNotifications =
      List.empty(growable: true);

  /* this function decides which notification state booleans to change and potentially returns the newest unactionable notification
     if the remote message contains an unactionable notification */
  static UnactionableNotification? handleForegroundNotification(
      RemoteMessage rm) {
    if (rm.notification == null) {
      return null;
    }
    print("NotificationManager.handleForegroundNotification(): I was called!");
    Map arguments = FirebaseApi.getDecodedNotificationArguments(rm);

    NotificationCodeKeys notificationKey =
        NotificationCodes.getCodeKey(arguments["notification_code"]);

    // actionable notification
    if (notificationKey == NotificationCodeKeys.FRIEND_REQUEST) {
      friendRequestNotificationIconEnabled = true;
    }
    // actionable notification
    else if (notificationKey == NotificationCodeKeys.ASSOCIATION_INVITATION) {
      associationInvitationNotificationIconEnabled = true;
    }
    // unactionable notifications
    else {
      UnactionableNotification un = UnactionableNotification.all(
        notificationKey,
        rm.notification!.title.toString(),
        rm.notification!.body.toString(),
      );

      unactionableNotifications.add(un);
      return un;
    }
  }

  // write background remote message to local front-end database
  static Future<bool> handleBackgroundNotification(RemoteMessage rm) async {
    bool result = false;
    if (rm.notification == null) {
      return result;
    }

    Map arguments = FirebaseApi.getDecodedNotificationArguments(rm);

    NotificationCodeKeys notificationCodeKey = NotificationCodes.getCodeKey(
      arguments["notification_code"],
    );

    if (notificationCodeKey == NotificationCodeKeys.FRIEND_REQUEST_RESPONSE) {
      QueryResult qr =
          await NotificationDatabase.insertFriendRequestResponseNotification(
        FriendRequestResponseNotification.all(
          rm.notification!.title!,
          rm.notification!.body!,
          arguments["recipient_id"],
          arguments["recipient_alias"],
        ),
      );
      result = qr.result;
    } else if (notificationCodeKey == NotificationCodeKeys.NONE ||
        notificationCodeKey == NotificationCodeKeys.FRIEND_REQUEST) {
      QueryResult qr = await NotificationDatabase.insertNotification(
        UnactionableNotification(
          notificationCodeKey,
          rm.notification!.title!,
          rm.notification!.body!,
        ),
      );
      result = qr.result;
    }

    return result;
  }

  /* Fetches the background notifications from the local SQL database and adds them to the unactionableNotifications list.
     This function does not reset the state of the unactionableNotifications list. The requesting stateful widget will need to 
     call setState() on unactionableNotifications. */
  static Future<QueryResult> importBackgroundUnactionableNotifications() async {
    QueryResult qr = await NotificationDatabase.getUnactionableNotifications();
    if (qr.result == false) {
      return qr;
    }

    for (UnactionableNotification un in qr.data) {
      unactionableNotifications.add(un);
    }

    // indicate whether there were any unactionable notifications in the front-end database
    qr.data = qr.data.isNotEmpty;
    return qr;
  }

  static Future<QueryResult>
      importBackgroundActionableNotificationCodeKeys() async {
    return await NotificationDatabase
        .getDistinctActionableNotificationCodeKeys();
  }

  // this should be called after all background notifications are read from the front-end database
  static Future<QueryResult> deleteBackgroundNotifications() async {
    return await NotificationDatabase.deleteNotifications();
  }
}

/* Firebase notifications include data about its type of notification. This enum is the front end version for interpreting
   notification types. Actionable notifications require user interaction and are persistent on the backend. Ephemeral notifications
   are sent once only and require no interaction from the user. */
enum NotificationCodeKeys {
  NONE // nothing
  ,
  FRIEND_REQUEST // actionable
  ,
  FRIEND_REQUEST_RESPONSE // ephemeral
  ,
  ASSOCIATION_INVITATION // actionable
}

abstract class NotificationCodes {
  static const Map<NotificationCodeKeys, int> _codes = {
    NotificationCodeKeys.NONE: 0,
    NotificationCodeKeys.FRIEND_REQUEST: 1,
    NotificationCodeKeys.FRIEND_REQUEST_RESPONSE: 2,
  };

  static const Map<int, NotificationCodeKeys> _codesReversed = {
    0: NotificationCodeKeys.NONE,
    1: NotificationCodeKeys.FRIEND_REQUEST,
    2: NotificationCodeKeys.FRIEND_REQUEST_RESPONSE,
  };

  static int getCodeValue(NotificationCodeKeys key) {
    return _codes[key]!;
  }

  static NotificationCodeKeys getCodeKey(int value) {
    return _codesReversed[value]!;
  }
}
