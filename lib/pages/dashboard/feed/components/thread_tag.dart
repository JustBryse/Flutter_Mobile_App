import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class FeedThreadTagWidget extends StatefulWidget {
  String _name = "None";
  String get name => _name;

  FeedThreadTagWidget({Key? key, required String name}) : super(key: key) {
    _name = name;
  }

  @override
  State<FeedThreadTagWidget> createState() => _FeedThreadTagWidgetState();
}

class _FeedThreadTagWidgetState extends State<FeedThreadTagWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Utility.primaryColor,
          border: Border.all(
            color: Utility.primaryColor,
            width: 0.5, //width of border
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: Text(
            widget._name,
            style: const TextStyle(color: Utility.secondaryColor),
          ),
        ),
      ),
    );
  }
}
