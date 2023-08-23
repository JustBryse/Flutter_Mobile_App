import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ProfileConfiguration extends StatefulWidget {
  const ProfileConfiguration({super.key});

  @override
  State<ProfileConfiguration> createState() => _ProfileConfigurationState();
}

class _ProfileConfigurationState extends State<ProfileConfiguration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
        actions: [],
      ),
      body: Stack(
        children: [],
      ),
    );
  }
}
