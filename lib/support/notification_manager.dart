// manages app-wide notification information
import 'package:cao_prototype/pages/dashboard/components/unactionable_notification_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';

abstract class NotificationManager {
  static bool friendRequestNotificationIconEnabled = false;
  static bool associationInvitationNotificationIconEnabled = false;

  // stores all the current unactionable notification widgets that should be visible in the notification menu
  static List<UnactionableNotification> unactionableNotifications =
      List.empty(growable: true);
}

// this object is mostly for holding ephemeral notifications like friend request responses
class UnactionableNotification {
  int _id = -1;
  NotificationCodeKeys _type = NotificationCodeKeys.NONE;
  String _title = "";
  String _body = "";

  int get id => _id;
  NotificationCodeKeys get type => _type;
  String get title => _title;
  String get body => _body;

  UnactionableNotification.all(
      NotificationCodeKeys type, String title, String body) {
    _id = generateUniqueId();
    _type = type;
    _title = title;
    _body = body;
  }

  UnactionableNotification.none();

  /* Generate an ephemeral ID for unique identification of unactionable notifications. No two current unactionable notifications
     are able to have the same ID. */
  int generateUniqueId() {
    int uid = 0;
    for (UnactionableNotification un
        in NotificationManager.unactionableNotifications) {
      if (un.id == uid) {
        ++uid;
      }
    }
    return uid;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id.toString(),
      "type": type.toString(),
      "title": title,
      "body": body
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  bool _equals(Object other) {
    if ((other is UnactionableNotification) == false) {
      return false;
    }

    UnactionableNotification un = other as UnactionableNotification;
    return type == un.type &&
        title == un.title &&
        body == un.body &&
        id == un.id;
  }

  @override
  bool operator ==(Object other) => _equals(other);
  @override
  int get hashCode => (id.toString() + type.toString() + title + body).hashCode;
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
