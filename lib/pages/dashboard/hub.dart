import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/pages/dashboard/navigation.dart';

class DashboardHub extends StatefulWidget {
  PageController _pageController = PageController();

  DashboardHub({Key? key, required PageController pc}) : super(key: key) {
    _pageController = pc;
  }

  @override
  State<DashboardHub> createState() => _DashboardHubState(_pageController);
}

class _DashboardHubState extends State<DashboardHub> {
  PageController _pageController = PageController();
  _DashboardHubState(PageController pc) {
    _pageController = pc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hub",
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
