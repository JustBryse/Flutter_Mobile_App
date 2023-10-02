import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';

class FriendRequestResponseNotification extends UnactionableNotification {
  int _recipientId = -1;
  String _recipientAlias = "";

  int get recipientId => _recipientId;
  String get recipientAlias => _recipientAlias;

  FriendRequestResponseNotification.all(
    String title,
    String body,
    int recipientId,
    String recipientAlias,
  ) : super(NotificationCodeKeys.FRIEND_REQUEST_RESPONSE, title, body) {
    _recipientId = recipientId;
    _recipientAlias = recipientAlias;
  }
}
