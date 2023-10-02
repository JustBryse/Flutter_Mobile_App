// this object is mostly for holding ephemeral notifications like friend request responses
import 'package:cao_prototype/notifications/notification_manager.dart';

class UnactionableNotification {
  int _id = -1;
  NotificationCodeKeys _type = NotificationCodeKeys.NONE;
  String _title = "";
  String _body = "";

  int get id => _id;
  NotificationCodeKeys get type => _type;
  String get title => _title;
  String get body => _body;

  UnactionableNotification(
      NotificationCodeKeys type, String title, String body) {
    _id = generateUniqueLocalId();
    _type = type;
    _title = title;
    _body = body;
  }

  UnactionableNotification.all(
      NotificationCodeKeys type, String title, String body) {
    _id = generateUniqueLocalId();
    _type = type;
    _title = title;
    _body = body;
  }

  UnactionableNotification.none();

  /* Generate an ephemeral ID for unique identification of unactionable notifications. No two current unactionable notifications
     are able to have the same ID. */
  int generateUniqueLocalId() {
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
