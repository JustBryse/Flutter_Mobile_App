import 'package:cao_prototype/models/friend_request.dart';
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

  FriendRequestWidget(
      {Key? key, required FriendRequest fr, required double width})
      : super(key: key) {
    _width = width;
    _fr = fr;
  }

  @override
  State<FriendRequestWidget> createState() => _FriendRequestWidgetState();
}

class _FriendRequestWidgetState extends State<FriendRequestWidget> {
  void acceptFriendRequest() {}
  void rejectFriendRequest() {}

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
                  onPressed: acceptFriendRequest,
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
