import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/pages/dashboard/dashboard.dart';

class DashboardNavigationRow extends StatelessWidget {
  PageController _pageController = PageController();

  DashboardNavigationRow.all({Key? key, required PageController pc})
      : super(key: key) {
    _pageController = pc;
  }

  void navigateToFeed() {
    _pageController.animateToPage(DashboardPage.pageIndexes["Feed"],
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  void navigateToHub() {
    _pageController.animateToPage(DashboardPage.pageIndexes["Hub"],
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  void navigateToBridge() {
    _pageController.animateToPage(DashboardPage.pageIndexes["Bridge"],
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  void navigateToMap() {
    _pageController.animateToPage(DashboardPage.pageIndexes["Map"],
        duration: const Duration(milliseconds: 500), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: navigateToBridge,
          icon: const Icon(Icons.newspaper),
          color: Utility.tertiaryColor,
        ),
        IconButton(
          onPressed: navigateToFeed,
          icon: const Icon(Icons.feed),
          color: Utility.tertiaryColor,
        ),
        IconButton(
          onPressed: navigateToHub,
          icon: const Icon(Icons.hub),
          color: Utility.tertiaryColor,
        ),
        IconButton(
          onPressed: navigateToMap,
          icon: const Icon(Icons.map),
          color: Utility.tertiaryColor,
        ),
      ],
    );
  }
}
