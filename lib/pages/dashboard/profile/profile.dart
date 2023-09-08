import 'package:cao_prototype/pages/dashboard/profile/components/notification.dart';
import 'package:cao_prototype/pages/dashboard/profile/social/social.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class DashboardProfile extends StatefulWidget {
  const DashboardProfile({super.key});

  @override
  State<DashboardProfile> createState() => _DashboardProfileState();
}

class _DashboardProfileState extends State<DashboardProfile> {
  List<NotificationWidget> notificationWidgets = List.empty(growable: true);

  void navigateToSavedThreadFeed() {}
  void navigateToSocialPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SocialPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.tertiaryColor,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
        backgroundColor: Utility.primaryColor,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.account_circle,
                    size: 100,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: navigateToSavedThreadFeed,
                      icon: const Icon(
                        Icons.home,
                        color: Utility.primaryColor,
                        size: 50,
                      ),
                    ),
                    IconButton(
                      onPressed: navigateToSocialPage,
                      icon: const Icon(
                        Icons.group,
                        color: Utility.primaryColor,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ),
              NotificationWidget(type: NotificationType.FRIEND_REQUEST),
              NotificationWidget(type: NotificationType.FRIEND_REQUEST),
              NotificationWidget(type: NotificationType.FRIEND_REQUEST),
              NotificationWidget(type: NotificationType.MISCELLANEOUS),
            ],
          ),
        ],
      ),
    );
  }
}
