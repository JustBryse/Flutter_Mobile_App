import 'package:cao_prototype/pages/dashboard/bridge/bridge.dart';
import 'package:cao_prototype/pages/dashboard/feed/feed.dart';
import 'package:cao_prototype/pages/dashboard/hub.dart';
import 'package:cao_prototype/pages/dashboard/map.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  static final Map<String, int> _pageIndexes = {
    "Bridge": 0,
    "Feed": 1,
    "Hub": 2,
    "Map": 3
  };
  static get pageIndexes => _pageIndexes;

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
  void navigateToMap() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.tertiaryColor,
      appBar: AppBar(
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
