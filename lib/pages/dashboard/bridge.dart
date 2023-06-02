import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/pages/dashboard/navigation.dart';

class DashboardBridge extends StatefulWidget {
  PageController _pageController = PageController();

  DashboardBridge({Key? key, required PageController pc}) : super(key: key) {
    _pageController = pc;
  }

  @override
  State<DashboardBridge> createState() =>
      _DashboardBridgeState(_pageController);
}

class _DashboardBridgeState extends State<DashboardBridge> {
  PageController _pageController = PageController();

  _DashboardBridgeState(PageController pc) {
    _pageController = pc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bridge",
          style: TextStyle(
            fontSize: Utility.titleFontSize,
            color: Utility.secondaryColor,
          ),
        ),
        backgroundColor: Utility.primaryColor,
      ),
      body: ListView(
        children: [],
      ),
      floatingActionButton: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          DashboardNavigationRow.all(pc: _pageController),
        ],
      ),
    );
  }
}
