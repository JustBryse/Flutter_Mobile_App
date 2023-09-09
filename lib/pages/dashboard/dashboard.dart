import 'package:cao_prototype/pages/dashboard/bridge/bridge.dart';
import 'package:cao_prototype/pages/dashboard/feed/feed.dart';
import 'package:cao_prototype/pages/dashboard/hub.dart';
import 'package:cao_prototype/pages/dashboard/map/map.dart';
import 'package:cao_prototype/pages/dashboard/profile/profile.dart';
import 'package:cao_prototype/tests/test_management.dart';
import 'package:cao_prototype/tests/unit_test_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

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

  void navigateToHub() {}

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
      backgroundColor: Utility.tertiaryColor,
      appBar: AppBar(
        actions: [
          if (TestManagement.isDeveloperModeEnabled)
            IconButton(
              onPressed: navigateToUnitTestDashboardPage,
              icon: const Icon(
                Icons.developer_board,
                color: Utility.secondaryColor,
              ),
            ),
          IconButton(
            onPressed: navigateToProfile,
            icon: const Icon(
              Icons.account_circle,
              color: Utility.secondaryColor,
            ),
          ),
        ],
        backgroundColor: Utility.primaryColor,
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Utility.secondaryColor),
        ),
      ),
      body: Column(
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
                onPressed: navigateToHub,
                icon: const Icon(
                  Icons.hub,
                  color: Utility.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
