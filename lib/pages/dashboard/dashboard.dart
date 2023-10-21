import 'dart:async';

import 'package:cao_prototype/firebase/firebase_api.dart';
import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/pages/components/pageview_selector.dart';
import 'package:cao_prototype/pages/dashboard/bridge/bridge.dart';
import 'package:cao_prototype/pages/dashboard/components/appbar_notification_button.dart';
import 'package:cao_prototype/pages/dashboard/components/appbar_notification_menu.dart';
import 'package:cao_prototype/pages/components/component_pages/notification_components/unactionable_notification_widget.dart';

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
  void Function() _jumpToMessages = () {};
  void Function() _jumpToNotifications = () {};
  void Function() _jumpToPageFromNavigationPathway = () {};
  PageViewSelector _pvs = PageViewSelector.none();
  DashboardPage({
    Key? key,
    required PageViewSelector pvs,
  }) : super(key: key) {
    _pvs = pvs;
  }

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void navigateToBridge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardBridge(),
      ),
    );
  }

  void navigateToFeed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardFeed(),
      ),
    );
  }

  void navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardProfile(),
      ),
    );
  }

  void navigateToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardMap(),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.primaryColor,
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
                    onPressed: navigateToBridge,
                    icon: const Icon(
                      Icons.question_answer,
                      color: Utility.tertiaryColor,
                    ),
                  ),
                  IconButton(
                    iconSize: 100,
                    padding: const EdgeInsets.all(16),
                    onPressed: navigateToFeed,
                    icon: const Icon(
                      Icons.feed,
                      color: Utility.tertiaryColor,
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
                    onPressed: navigateToMap,
                    icon: const Icon(
                      Icons.map,
                      color: Utility.tertiaryColor,
                    ),
                  ),
                  IconButton(
                    iconSize: 100,
                    padding: const EdgeInsets.all(16),
                    onPressed: navigateToProfile,
                    icon: const Icon(
                      Icons.account_circle_rounded,
                      color: Utility.tertiaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: widget._pvs,
          ),
        ],
      ),
    );
  }
}
