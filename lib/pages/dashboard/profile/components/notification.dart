import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

enum NotificationType { FRIEND_REQUEST, MISCELLANEOUS }

class NotificationWidget extends StatefulWidget {
  NotificationType _notificationType = NotificationType.MISCELLANEOUS;
  NotificationType get notificationType => _notificationType;
  NotificationWidget({Key? key, required NotificationType type})
      : super(key: key) {
    _notificationType = type;
  }

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
