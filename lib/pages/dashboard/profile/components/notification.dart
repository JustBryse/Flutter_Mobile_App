import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class NotificationWidget extends StatefulWidget {
  String _title = "";
  String get title => _title;

  NotificationWidget({
    Key? key,
    required String title,
  }) : super(key: key) {
    _title = title;
  }

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
