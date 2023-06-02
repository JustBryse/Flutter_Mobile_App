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
          onPressed: navigateToFeed,
          icon: const Icon(Icons.feed),
        ),
        IconButton(
          onPressed: navigateToHub,
          icon: const Icon(Icons.hub),
        ),
        IconButton(
          onPressed: navigateToBridge,
          icon: const Icon(Icons.water),
        ),
        IconButton(
          onPressed: navigateToMap,
          icon: const Icon(Icons.map),
        ),
      ],
    );
  }
}
