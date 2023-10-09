import 'package:cao_prototype/models/friend_request.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class FriendRequestWidget extends StatefulWidget {
  FriendRequest _fr = FriendRequest.empty();
  FriendRequest get fr => _fr;

  double _width = -1;
  double get width => _width;

  // Respond to the friend request (accept/reject). Informs the parent widget to remove this widget from the friend request menu
  void Function(FriendRequest) _deleteWidget = (fr) => null;

  FriendRequestWidget({
    Key? key,
    required FriendRequest fr,
    required double width,
    required void Function(FriendRequest) deleteWidget,
  }) : super(key: key) {
    _width = width;
    _fr = fr;
    _deleteWidget = deleteWidget;
  }

  @override
  State<FriendRequestWidget> createState() => _FriendRequestWidgetState();
}

class _FriendRequestWidgetState extends State<FriendRequestWidget> {
  // accepts the friend request and deletes this widget
  void acceptFriendRequest() async {
    QueryResult qr = await BasicFriendRequest.acceptFriendRequest(
      BasicFriendRequest.fetch(
        widget.fr.requesterId,
        widget.fr.recipientId,
        widget.fr.insertDate,
        widget.fr.editDate,
      ),
    );
    print("accept friend request: " + qr.toString());

    if (qr.result == true) {
      widget._deleteWidget(widget.fr);
    } else {
      Utility.displayAlertMessage(context, "Failed to Accept",
          "There was a problem with accepting the friend request.");
    }
  }

  // rejects the friend request and deletes this widget
  void rejectFriendRequest() async {
    QueryResult qr = await BasicFriendRequest.rejectFriendRequest(
      BasicFriendRequest.fetch(
        widget.fr.requesterId,
        widget.fr.recipientId,
        widget.fr.insertDate,
        widget.fr.editDate,
      ),
    );
    print("reject friend request: " + qr.toString());
    if (qr.result == true) {
      widget._deleteWidget(widget.fr);
    } else {
      Utility.displayAlertMessage(context, "Failed to Reject",
          "There was a problem with rejecting the friend request.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: const BoxDecoration(
          color: Utility.tertiaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "Friend Request",
                    style: TextStyle(color: Utility.primaryColor, fontSize: 20),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "From ${widget.fr.requester.alias} (#${widget.fr.requester.id})",
                    style: const TextStyle(
                      color: Utility.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: acceptFriendRequest,
                  icon: const Icon(
                    Icons.person_add_rounded,
                    color: Utility.primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: rejectFriendRequest,
                  icon: const Icon(
                    Icons.person_remove_rounded,
                    color: Utility.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
