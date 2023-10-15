import 'package:cao_prototype/models/friend.dart';
import 'package:cao_prototype/models/structures/user_profile.dart';
import 'package:cao_prototype/pages/dashboard/profile/external_profile.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class FriendWidget extends StatefulWidget {
  Friend _friend = Friend.none();
  Friend get friend => _friend;
  double _width = -1;
  double get width => _width;
  // tells the social page to refresh friends and contact data
  void Function() _getFriendsAndContacts = () {};

  FriendWidget({
    Key? key,
    required Friend friend,
    required double width,
    required void Function() getFriendsAndContacts,
  }) : super(key: key) {
    _friend = friend;
    _width = width;
    _getFriendsAndContacts = getFriendsAndContacts;
  }

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  // navigate to direct messaging page
  void navigateToDirectMessagesPage() {}
  void navigateToExternalProfilePage() async {
    QueryResult qr = await UserProfile.getUserProfile(
      Session.currentUser.id,
      widget.friend.friendedId,
    );

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "User Profile Error", "Failed to get user profile.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExternalProfilePage(
          userProfile: qr.data,
        ),
      ),
    ).then((value) => widget._getFriendsAndContacts());
  }

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
                    onPressed: navigateToExternalProfilePage,
                    icon: const Icon(
                      Icons.home,
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
