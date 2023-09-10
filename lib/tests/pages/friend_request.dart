import 'package:cao_prototype/models/friend_request.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class FriendRequestUnitTestPage extends StatefulWidget {
  const FriendRequestUnitTestPage({super.key});

  @override
  State<FriendRequestUnitTestPage> createState() =>
      _FriendRequestUnitTestPageState();
}

class _FriendRequestUnitTestPageState extends State<FriendRequestUnitTestPage> {
  void getRecipientFriendRequests() async {
    QueryResult qr = await FriendRequest.getRecipientFriendRequests();

    if (qr.result == false) {
      Utility.displayAlertMessage(
        context,
        "Failure Result",
        "Result Code: ${ResultCodes.getCodeKey(qr.resultCode).name}.\nMessage: ${qr.message}",
      );
      return;
    }

    for (FriendRequest fr in qr.data) {
      print(fr.toString() + "\n");
    }

    Utility.displayAlertMessage(context, "Success Result", "");
  }

  void getRequesterFriendRequests() async {
    QueryResult qr = await FriendRequest.getRequesterFriendRequests();

    if (qr.result == false) {
      Utility.displayAlertMessage(
        context,
        "Failure Result",
        "Result Code: ${ResultCodes.getCodeKey(qr.resultCode).name}.\nMessage: ${qr.message}",
      );
      return;
    }

    for (FriendRequest fr in qr.data) {
      print(fr.toString() + "\n");
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
      body: ListView(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: TextButton(
                onPressed: getRecipientFriendRequests,
                child: const Text(
                  "Get Recipient Friend Requests",
                  style: TextStyle(
                    color: Utility.secondaryColor,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: TextButton(
                onPressed: getRequesterFriendRequests,
                child: const Text(
                  "Get Requester Friend Requests",
                  style: TextStyle(
                    color: Utility.secondaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
