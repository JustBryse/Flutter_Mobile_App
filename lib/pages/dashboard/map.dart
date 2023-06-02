import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/pages/dashboard/navigation.dart';

class DashboardMap extends StatefulWidget {
  PageController _pageController = PageController();

  DashboardMap({Key? key, required PageController pc}) : super(key: key) {
    _pageController = pc;
  }

  @override
  State<DashboardMap> createState() => _DashboardMapState(_pageController);
}

class _DashboardMapState extends State<DashboardMap> {
  PageController _pageController = PageController();
  _DashboardMapState(PageController pc) {
    _pageController = pc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Map",
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
