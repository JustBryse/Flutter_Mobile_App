import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class UnactionableNotificationWidget extends StatefulWidget {
  UnactionableNotification _un = UnactionableNotification.none();
  UnactionableNotification get un => _un;

  double _width = -1;
  double get width => _width;

  /* The delete function is dependent on the parent widget (notification menu) because the menu may want to do other things during
     the deletion process. This is not necessarily required, but I am just future-proofing this feature. */
  bool Function(UnactionableNotification) _deleteNotification = (un) => false;

  UnactionableNotificationWidget({
    Key? key,
    required UnactionableNotification un,
    required double width,
    required bool Function(UnactionableNotification) deleteNotification,
  }) : super(key: key) {
    _un = un;
    _width = width;
    _deleteNotification = deleteNotification;
  }

  @override
  State<UnactionableNotificationWidget> createState() =>
      _UnactionableNotificationWidgetState();
}

class _UnactionableNotificationWidgetState
    extends State<UnactionableNotificationWidget> {
  // tell the parent
  void deleteNotification() {
    widget._deleteNotification(widget.un);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Utility.tertiaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        width: widget.width,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (widget.un.type == NotificationCodeKeys.NONE)
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.mail_rounded,
                      color: Utility.primaryColor,
                    ),
                  ),
                if (widget.un.type ==
                    NotificationCodeKeys.FRIEND_REQUEST_RESPONSE)
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.person_add_rounded,
                      color: Utility.primaryColor,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    widget.un.title,
                    style: const TextStyle(
                        color: Utility.primaryColor, fontSize: 20),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    widget.un.body,
                    style: const TextStyle(
                      color: Utility.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: deleteNotification,
                  icon: const Icon(
                    Icons.delete,
                    color: Utility.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
