import 'dart:async';

import 'package:cao_prototype/firebase/firebase_api.dart';
import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/pages/dashboard/bridge/bridge.dart';
import 'package:cao_prototype/pages/dashboard/components/appbar_notification_button.dart';
import 'package:cao_prototype/pages/dashboard/components/appbar_notification_menu.dart';
import 'package:cao_prototype/pages/dashboard/components/unactionable_notification_widget.dart';

import 'package:cao_prototype/pages/dashboard/feed/feed.dart';
import 'package:cao_prototype/pages/dashboard/hub.dart';
import 'package:cao_prototype/pages/dashboard/map/map.dart';
import 'package:cao_prototype/pages/dashboard/profile/profile.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/tests/test_management.dart';
import 'package:cao_prototype/tests/pages/unit_test_dashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isNotificationMenuVisible = false;
  /* holds the local notification widgets that are displayed in the notification menu. This menu is local and needs to be updated
    when returning from other pages to be syncrhonized with the current notifications from the notification manager */
  List<UnactionableNotificationWidget> unactionableNotificationWidgets =
      List.empty(growable: true);

  void navigateToBridge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardBridge(),
      ),
    ).then((value) => refreshUnactionableNotificationWidgets());
  }

  void navigateToFeed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardFeed(),
      ),
    ).then((value) => refreshUnactionableNotificationWidgets());
  }

  void navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardProfile(),
      ),
    ).then((value) => refreshUnactionableNotificationWidgets());
  }

  void navigateToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardMap(),
      ),
    ).then((value) => refreshUnactionableNotificationWidgets());
  }

  // allows the user to visit the unit testing dashboard where unit tests can be run (only accessible in developer mode)
  void navigateToUnitTestDashboardPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UnitTestDashboardPage(),
      ),
    );
  }

  /* This is called by the appbar notification button when the page state resumes (when the app opens on this page).
     This function refreshes the currently displayed notification widgets with the current ones in the unactionableNotifications list. */
  void refreshUnactionableNotificationWidgets() {
    unactionableNotificationWidgets.clear();

    for (UnactionableNotification un
        in NotificationManager.unactionableNotifications) {
      unactionableNotificationWidgets.add(
        UnactionableNotificationWidget(
          un: un,
          width: MediaQuery.of(context).size.width * 0.9,
          deleteNotification: deleteUnactionableNotificationWidget,
        ),
      );
    }
    setState(() {
      unactionableNotificationWidgets;
    });
  }

  // Firebase remote message handler. This function is actually called by the appbar account button widget on firebase events
  void handleForegroundFirebaseMessage(RemoteMessage rm) {
    if (rm.notification == null) {
      return;
    }

    UnactionableNotification? un =
        NotificationManager.handleForegroundNotification(rm);
    // add unactionable notifications to the widget list
    if (un != null) {
      UnactionableNotificationWidget unw = UnactionableNotificationWidget(
        un: un,
        width: MediaQuery.of(context).size.width * 0.9,
        deleteNotification: deleteUnactionableNotificationWidget,
      );

      setState(() {
        unactionableNotificationWidgets.add(unw);
        NotificationManager.friendRequestNotificationIconEnabled;
        NotificationManager.associationInvitationNotificationIconEnabled;
      });
    }
  }

  /* Called from the appbar notification button when returning from the background state. If actionable notifications were recieved
  while in the background state, the corrosponding notification code keys will be sent here and the associated menu icons will be 
  enabled to tell the user that there are pending actionable notifications. */
  void enableActionableNotificationMenuIcons(List<NotificationCodeKeys> ncks) {
    for (NotificationCodeKeys nck in ncks) {
      if (nck == NotificationCodeKeys.FRIEND_REQUEST) {
        NotificationManager.friendRequestNotificationIconEnabled = true;
      } else if (nck == NotificationCodeKeys.ASSOCIATION_INVITATION) {
        NotificationManager.associationInvitationNotificationIconEnabled = true;
      }
    }

    setState(() {
      NotificationManager.friendRequestNotificationIconEnabled;
      NotificationManager.associationInvitationNotificationIconEnabled;
    });
  }

  void toggleProfileMenu(bool flag) {
    setState(() {
      isNotificationMenuVisible = flag;
    });
  }

  bool deleteUnactionableNotificationWidget(UnactionableNotification un) {
    int removableIndex = -1;

    for (int i = 0; i < unactionableNotificationWidgets.length; ++i) {
      if (unactionableNotificationWidgets[i].un.id == un.id) {
        removableIndex = i;
        NotificationManager.unactionableNotifications.remove(un);
        break;
      }
    }

    if (removableIndex == -1) {
      return false;
    }

    setState(() {
      unactionableNotificationWidgets.removeAt(removableIndex);
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.tertiaryColor,
      appBar: AppBar(
        actions: [
          if (TestManagement.isDeveloperModeEnabled)
            IconButton(
              onPressed: navigateToUnitTestDashboardPage,
              icon: const Icon(
                Icons.work_rounded,
                color: Colors.orange,
              ),
            ),
          AppBarNotificationButton(
            toggleProfileMenu: toggleProfileMenu,
            firebaseForegroundMessageHandler: handleForegroundFirebaseMessage,
            refreshUnactionableNotificationWidgets:
                refreshUnactionableNotificationWidgets,
            enableActionableNotificationMenuIcons:
                enableActionableNotificationMenuIcons,
          ),
        ],
        backgroundColor: Utility.primaryColor,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Utility.secondaryColor),
        ),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 100,
                    padding: const EdgeInsets.all(16),
                    color: Utility.tertiaryColor,
                    onPressed: navigateToBridge,
                    icon: const Icon(
                      Icons.question_answer,
                      color: Utility.primaryColor,
                    ),
                  ),
                  IconButton(
                    iconSize: 100,
                    padding: const EdgeInsets.all(16),
                    color: Utility.tertiaryColor,
                    onPressed: navigateToFeed,
                    icon: const Icon(
                      Icons.feed,
                      color: Utility.primaryColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 100,
                    padding: const EdgeInsets.all(16),
                    color: Utility.tertiaryColor,
                    onPressed: navigateToMap,
                    icon: const Icon(
                      Icons.map,
                      color: Utility.primaryColor,
                    ),
                  ),
                  IconButton(
                    iconSize: 100,
                    padding: const EdgeInsets.all(16),
                    color: Utility.tertiaryColor,
                    onPressed: navigateToProfile,
                    icon: const Icon(
                      Icons.account_circle_rounded,
                      color: Utility.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Visibility(
            visible: isNotificationMenuVisible,
            child: AppBarNotificationMenu(
              notificationWidth: MediaQuery.of(context).size.width * 0.9,
              unactionableNotificationWidgets: unactionableNotificationWidgets,
            ),
          ),
        ],
      ),
    );
  }
}
