import 'package:cao_prototype/models/friend.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class FriendWidget extends StatefulWidget {
  void Function(Friend) _deleteWidget = (p0) => null;
  Friend _friend = Friend.none();
  Friend get friend => _friend;
  double _width = -1;
  double get width => _width;

  FriendWidget({
    Key? key,
    required Function(Friend) deleteWidget,
    required Friend friend,
    required double width,
  }) : super(key: key) {
    _deleteWidget = deleteWidget;
    _friend = friend;
    _width = width;
  }

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  // delete this friend and tell the parent widget to delete this widget
  void deleteFriend() async {
    QueryResult qr = await BasicFriend.deleteFriend(
      BasicFriend(
        widget.friend.frienderId,
        widget.friend.friendedId,
      ),
    );

    if (qr.result) {
      widget._deleteWidget(widget.friend);
    } else {
      Utility.displayAlertMessage(
          context, "Failed to Delete", "Failed to delete friend");
    }
  }

  // navigate to direct messaging page
  void navigateToDirectMessagesPage() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        width: widget.width,
        decoration: const BoxDecoration(
          color: Utility.tertiaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.person_rounded,
                    color: Utility.primaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    "${widget.friend.friended.alias} (#${widget.friend.friended.id})",
                    style: const TextStyle(color: Utility.primaryColor),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: IconButton(
                    onPressed: navigateToDirectMessagesPage,
                    icon: const Icon(
                      Icons.message,
                      color: Utility.primaryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: IconButton(
                    onPressed: deleteFriend,
                    icon: const Icon(
                      Icons.person_remove_rounded,
                      color: Utility.primaryColor,
                    ),
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
