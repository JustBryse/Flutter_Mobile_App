import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/tests/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class UnitTestDashboardPage extends StatefulWidget {
  const UnitTestDashboardPage({super.key});

  @override
  State<UnitTestDashboardPage> createState() => _UnitTestDashboardPageState();
}

class _UnitTestDashboardPageState extends State<UnitTestDashboardPage> {
  void navigateToContactTestPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ContactUnitTestPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.tertiaryColor,
      appBar: AppBar(
        title: const Text(
          "Unit Test Dashboard",
          style: TextStyle(color: Utility.secondaryColor),
        ),
      ),
      body: ListView(
        children: [
          TextButton(
            onPressed: navigateToContactTestPage,
            child: const Text(
              "Contact Unit Tests",
              style: TextStyle(
                color: Utility.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
