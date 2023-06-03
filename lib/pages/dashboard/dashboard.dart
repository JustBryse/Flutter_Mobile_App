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
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        children: [
          DashboardBridge(pc: pageController),
          DashboardFeed(pc: pageController),
          DashboardHub(pc: pageController),
          DashboardMap(pc: pageController),
        ],
      ),
    );
  }
}
