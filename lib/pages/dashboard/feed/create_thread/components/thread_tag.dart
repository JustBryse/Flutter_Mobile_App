import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class ThreadTagWidget extends StatefulWidget {
  String _name = "None";
  String get name => _name;

  Function(ThreadTagWidget) _removeThreadTag = (p0) {};

  ThreadTagWidget(
      {Key? key,
      required String name,
      required Function(ThreadTagWidget) removeThreadTag})
      : super(key: key) {
    _name = name;
    _removeThreadTag = removeThreadTag;
  }

  @override
  State<ThreadTagWidget> createState() => _ThreadTagWidgetState();
}

class _ThreadTagWidgetState extends State<ThreadTagWidget> {
  removeThreadTag() {
    widget._removeThreadTag(widget);
  }

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
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: Text(
                widget._name,
                style: const TextStyle(color: Utility.secondaryColor),
              ),
            ),
            IconButton(
              onPressed: removeThreadTag,
              icon: const Icon(
                Icons.cancel,
                color: Utility.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
