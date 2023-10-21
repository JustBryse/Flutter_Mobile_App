import 'package:cao_prototype/pages/components/pageview_selector.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MessagePage extends StatefulWidget {
  PageViewSelector _pvs = PageViewSelector.none();
  MessagePage({Key? key, required PageViewSelector pvs}) : super(key: key) {
    _pvs = pvs;
  }

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Widget? buildMessageWidgets(BuildContext, int index) {
    if (index == 0) {
      return Text(
        "Messages Page",
        style: TextStyle(color: Utility.secondaryColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.primaryColor,
      appBar: AppBar(
        backgroundColor: Utility.primaryColor,
        title: const Text(
          "Messages",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemBuilder: buildMessageWidgets,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: widget._pvs,
          ),
        ],
      ),
    );
  }
}
