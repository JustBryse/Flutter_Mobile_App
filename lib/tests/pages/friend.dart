import 'package:cao_prototype/models/friend.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class FriendUnitTestPage extends StatefulWidget {
  const FriendUnitTestPage({super.key});

  @override
  State<FriendUnitTestPage> createState() => _FriendUnitTestPageState();
}

class _FriendUnitTestPageState extends State<FriendUnitTestPage> {
  void getFriends() async {
    QueryResult qr = await Friend.getFriends();

    if (qr.result == false) {
      Utility.displayAlertMessage(
        context,
        "Failure Result",
        "Result Code: " +
            ResultCodes.getCodeKey(qr.resultCode).name +
            ".\nMessage: " +
            qr.message,
      );
      return;
    }

    for (Friend f in qr.data) {
      print("Friend: " + f.toString() + "\n");
    }

    Utility.displayAlertMessage(context, "Success Result", "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text(
          "Friend Unit Test Page",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          color: Colors.blue,
          child: TextButton(
            onPressed: getFriends,
            child: const Text(
              "Get Friends",
              style: TextStyle(
                color: Utility.secondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
