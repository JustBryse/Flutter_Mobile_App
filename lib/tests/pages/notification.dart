import 'package:cao_prototype/notifications/models/friend_request_response_notification.dart';
import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/notifications/notification_database.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class NotificationUnitTestPage extends StatefulWidget {
  const NotificationUnitTestPage({super.key});

  @override
  State<NotificationUnitTestPage> createState() =>
      _NotificationUnitTestPageState();
}

class _NotificationUnitTestPageState extends State<NotificationUnitTestPage> {
  void insertFriendRequestResponse() async {
    FriendRequestResponseNotification frrn =
        FriendRequestResponseNotification.all(
      "New Friend",
      "Jupyter is now your friend",
      134,
      "Jupyter",
    );
    QueryResult qr =
        await NotificationDatabase.insertFriendRequestResponseNotification(
      frrn,
    );
    print("QueryResult of insertFriendRequestResponse(): " + qr.toString());
  }

  void insertUnactionableNotification() async {
    UnactionableNotification un = UnactionableNotification.all(
        NotificationCodeKeys.NONE, "Message", "This is a message");
    QueryResult qr = await NotificationDatabase.insertNotification(
      un,
    );

    print("QueryResult of insertUnactionableNotification(): " + qr.toString());
  }

  void deleteUnactionableNotifications() async {
    QueryResult qr = await NotificationDatabase.deleteNotifications();
    print("QueryResult of deleteUnactionableNotifications(): " + qr.toString());
  }

  void getUnactionableNotifications() async {
    QueryResult qr = await NotificationDatabase.getUnactionableNotifications();
    print("QueryResult of getUnactionableNotifications(): " + qr.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text(
          "Notification Database Test Page",
          style: TextStyle(color: Utility.secondaryColor),
        ),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextButton(
              onPressed: deleteUnactionableNotifications,
              child: const Text(
                "Delete Unactionable Notifications",
                style: TextStyle(color: Utility.secondaryColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextButton(
              onPressed: insertUnactionableNotification,
              child: const Text(
                "Insert Unactionable Notification",
                style: TextStyle(color: Utility.secondaryColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextButton(
              onPressed: insertFriendRequestResponse,
              child: const Text(
                "Insert Friend Request Response",
                style: TextStyle(color: Utility.secondaryColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextButton(
              onPressed: getUnactionableNotifications,
              child: const Text(
                "Get Unactionable Notifications",
                style: TextStyle(color: Utility.secondaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
