import 'dart:convert';

import 'package:cao_prototype/models/contact.dart';
import 'package:cao_prototype/models/friend.dart';
import 'package:cao_prototype/models/friend_request.dart';
import 'package:cao_prototype/models/individual.dart';
import 'package:cao_prototype/models/organization.dart';
import 'package:cao_prototype/models/structures/user_profile.dart';
import 'package:cao_prototype/models/structures/user_relationship.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

// this page represents the public-facing profile page of a user
class ExternalProfilePage extends StatefulWidget {
  UserProfile _userProfile = UserProfile.none();
  UserProfile get userProfile => _userProfile;

  ExternalProfilePage({
    Key? key,
    required UserProfile userProfile,
  }) : super(key: key) {
    _userProfile = userProfile;
  }

  @override
  State<ExternalProfilePage> createState() => _ExternalProfilePageState();
}

class _ExternalProfilePageState extends State<ExternalProfilePage> {
  UserProfile mutableUserProfile = UserProfile.none();

  @override
  void initState() {
    mutableUserProfile = widget.userProfile;
  }

  /* typically after a relationship operation has ended, this function is called to update the user relationship status between 
  the profile observer and the observed profile user */
  Future<void> getUserRelationship() async {
    QueryResult qr = await UserRelationship.getUserRelationship(
      Session.currentUser.id,
      mutableUserProfile.user.id,
    );

    if (qr.result) {
      // update all the UI widgets that depend on the relationship between the observer user and observed user
      setState(() {
        mutableUserProfile.setUserRelationship(qr.data);
      });
    } else {
      Utility.displayAlertMessage(context, "Profile Update Failed",
          "Failed to get the updated user relationship status.");
    }
  }

  void addContact() async {
    QueryResult qr = await BasicContact.createContact(
      BasicContact(
        Session.currentUser.id,
        mutableUserProfile.user.id,
      ),
    );

    if (qr.result == false) {
      Utility.displayAlertMessage(context, "Failure",
          "Failed to add ${mutableUserProfile.user.alias} as a contact");
    } else {
      Utility.displayAlertMessage(context, "Success",
          "${mutableUserProfile.user.alias} was added as a contact.");
      await getUserRelationship();
    }
  }

  void sendFriendRequest() async {
    QueryResult qr = await BasicFriendRequest.createFriendRequest(
      BasicFriendRequest(
        Session.currentUser.id,
        mutableUserProfile.user.id,
      ),
    );

    if (qr.result) {
      Utility.displayAlertMessage(context, "Success",
          "Successfully sent a friend request to ${mutableUserProfile.user.alias}");
      await getUserRelationship();
    } else {
      Utility.displayAlertMessage(context, "Failure",
          "Failed to send a friend request to ${mutableUserProfile.user.alias}");
    }
  }

  void rescindFriendRequest() async {
    QueryResult qr = await BasicFriendRequest.rescindFriendRequest(
      BasicFriendRequest(
        Session.currentUser.id,
        mutableUserProfile.user.id,
      ),
    );

    if (qr.result) {
      Utility.displayAlertMessage(context, "Success",
          "Successfuly rescined the friend request to ${mutableUserProfile.user.alias}");
      await getUserRelationship();
    } else {
      Utility.displayAlertMessage(context, "Failure",
          "Failed to rescind the friend request to ${mutableUserProfile.user.alias}");
    }
  }

  void removeFriend() async {
    QueryResult qr = await BasicFriend.deleteFriend(
      BasicFriend(
        Session.currentUser.id,
        mutableUserProfile.user.id,
      ),
    );

    if (qr.result) {
      Utility.displayAlertMessage(context, "Success",
          "${mutableUserProfile.user.alias} is no longer a friend");
      await getUserRelationship();
    } else {
      Utility.displayAlertMessage(context, "Failure",
          "Failed to end friendship with ${mutableUserProfile.user.alias}");
    }
  }

  void removeContact() async {
    QueryResult qr = await BasicContact.deleteContact(
      BasicContact(
        Session.currentUser.id,
        mutableUserProfile.user.id,
      ),
    );

    if (qr.result) {
      Utility.displayAlertMessage(context, "Success",
          "${mutableUserProfile.user.alias} is no longer a contact");
      await getUserRelationship();
    } else {
      Utility.displayAlertMessage(context, "Failure",
          "Failed to remove ${mutableUserProfile.user.alias} from contacts");
    }
  }

  // a button for adding or removing the user as a contact
  Widget buildContactButton() {
    if (mutableUserProfile.ur.contactExists == false) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: TextButton(
          onPressed: addContact,
          child: const Text(
            "Add Contact",
            style: TextStyle(
              color: Utility.secondaryColor,
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: TextButton(
          onPressed: removeContact,
          child: const Text(
            "Remove Contact",
            style: TextStyle(
              color: Utility.secondaryColor,
            ),
          ),
        ),
      );
    }
  }

  // a button for managing friendship (removing a friend, sending a friend request)
  Widget buildFriendButton() {
    // if no friendship exists and no friend request exists, then it is ok to send a friend request
    if (mutableUserProfile.ur.friendshipExists == false &&
        mutableUserProfile.ur.friendRequestExists == false) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: TextButton(
          onPressed: sendFriendRequest,
          child: const Text(
            "Add Friend",
            style: TextStyle(
              color: Utility.secondaryColor,
            ),
          ),
        ),
      );
      // if friendship does not exist but friend request does exist, then allow for the request to be rescinded
    } else if (mutableUserProfile.ur.friendshipExists == false &&
        mutableUserProfile.ur.friendRequestExists) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: TextButton(
          onPressed: removeFriend,
          child: const Text(
            "Cancel Friend Request",
            style: TextStyle(
              color: Utility.secondaryColor,
            ),
          ),
        ),
      );
      // if the friendship does exist, then allow for the user to end the friendship
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: TextButton(
          onPressed: removeFriend,
          child: const Text(
            "Remove Friend",
            style: TextStyle(
              color: Utility.secondaryColor,
            ),
          ),
        ),
      );
    }
  }

  // return identifying information about the user such as their name (not alias) and other biographical information
  Widget buildBiographyWidget() {
    Widget result = const Text("");

    if (mutableUserProfile.user is Individual) {
      Individual user = mutableUserProfile.user as Individual;
      result = Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          "${user.firstName} ${user.lastName}",
          style: const TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      );
    } else if (mutableUserProfile.user is Organization) {
      Organization user = mutableUserProfile.user as Organization;
      result = Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          user.name,
          style: const TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      );
    }

    return result;
  }

  Widget buildUserIconWidget() {
    Widget icon = const Icon(Icons.abc);

    if (mutableUserProfile.user is Individual) {
      icon = const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.account_circle_rounded,
          color: Utility.tertiaryColor,
          size: 100,
        ),
      );
    } else if (mutableUserProfile.user is Organization) {
      icon = const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.groups,
          color: Utility.tertiaryColor,
          size: 100,
        ),
      );
    }

    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.primaryColor,
      appBar: AppBar(
        backgroundColor: Utility.primaryColor,
        title: Text(
          widget.userProfile.user.alias,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              buildUserIconWidget(),
              buildBiographyWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildContactButton(),
                  buildFriendButton(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
