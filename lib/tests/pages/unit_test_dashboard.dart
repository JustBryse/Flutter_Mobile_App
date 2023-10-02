import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/tests/pages/contact.dart';
import 'package:cao_prototype/tests/pages/friend.dart';
import 'package:cao_prototype/tests/pages/friend_request.dart';
import 'package:cao_prototype/tests/pages/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class UnitTestDashboardPage extends StatefulWidget {
  const UnitTestDashboardPage({super.key});

  @override
  State<UnitTestDashboardPage> createState() => _UnitTestDashboardPageState();
}

class _UnitTestDashboardPageState extends State<UnitTestDashboardPage> {
  void navigateToContactTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ContactUnitTestPage(),
      ),
    );
  }

  void navigateToFriendTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FriendUnitTestPage(),
      ),
    );
  }

  void navigateToFriendRequestTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FriendRequestUnitTestPage(),
      ),
    );
  }

  void navigateToNotificationTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationUnitTestPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text(
          "Unit Test Dashboard",
          style: TextStyle(color: Utility.secondaryColor),
        ),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: [
          TextButton(
            onPressed: navigateToContactTestPage,
            child: const Text(
              "Contact Unit Tests",
              style: TextStyle(
                color: Utility.secondaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextButton(
              onPressed: navigateToFriendTestPage,
              child: const Text(
                "Friend Unit Tests",
                style: TextStyle(
                  color: Utility.secondaryColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextButton(
              onPressed: navigateToFriendRequestTestPage,
              child: const Text(
                "FriendRequest Unit Tests",
                style: TextStyle(
                  color: Utility.secondaryColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextButton(
              onPressed: navigateToNotificationTestPage,
              child: const Text(
                "Notification Database Unit Tests",
                style: TextStyle(
                  color: Utility.secondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
