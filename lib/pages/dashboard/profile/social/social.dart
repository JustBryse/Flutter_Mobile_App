import 'package:cao_prototype/models/contact.dart';
import 'package:cao_prototype/models/friend.dart';
import 'package:cao_prototype/pages/dashboard/profile/social/components/contact_widget.dart';
import 'package:cao_prototype/pages/dashboard/profile/social/components/friend_widget.dart';
import 'package:cao_prototype/pages/dashboard/profile/social/components/social_search_menu.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

enum RelationshipTypes { CONTACT, FRIEND }

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  // controls whether to show friend widgets, contact widgets, etc...
  RelationshipTypes selectedRelationshipType = RelationshipTypes.FRIEND;
  // controls the current state of the switch widget
  bool relationshipTypeSwitchFlag = false;
  // controls whether the user search menu is visible
  bool isSocialSearchMenuVisible = false;

  List<Friend> friends = List.empty(growable: true);
  List<Contact> contacts = List.empty(growable: true);
  List<FriendWidget> friendWidgets = List.empty(growable: true);
  List<ContactWidget> contactWidgets = List.empty(growable: true);

  String appBarTitle = "Title";
  Icon socialSearchMenuIcon =
      const Icon(Icons.search, color: Utility.secondaryColor);

  @override
  void initState() {
    getFriends();
    getContacts();
    setAppBarTitleBySelectedRelationshipType();
  }

  void setAppBarTitleBySelectedRelationshipType() {
    if (selectedRelationshipType == RelationshipTypes.CONTACT) {
      appBarTitle = "Contacts";
    } else if (selectedRelationshipType == RelationshipTypes.FRIEND) {
      appBarTitle = "Friends";
    }

    setState(() {
      appBarTitle;
    });
  }

  // gets friends from server
  void getFriends() async {
    friends.clear();
    friendWidgets.clear();
    QueryResult qr = await Friend.getFriends();

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "Failed to Get Friends", "Please try again");
      return;
    }

    double width = MediaQuery.of(context).size.width * 0.9;
    for (Friend f in qr.data) {
      friends.add(f);
      friendWidgets.add(
        FriendWidget(
          deleteWidget: deleteFriendWidget,
          friend: f,
          width: width,
        ),
      );
    }

    setState(() {
      friendWidgets;
    });
  }

  // fetches contacts form server
  void getContacts() async {
    contacts.clear();
    contactWidgets.clear();
    QueryResult qr = await Contact.getContacts();

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "Failed to Get Contacts", "Please try again.");
      return;
    }

    double width = MediaQuery.of(context).size.width;
    for (Contact c in qr.data) {
      contacts.add(c);
      contactWidgets.add(
        ContactWidget(
          width: width,
          deleteWidget: deleteContactWidget,
          contact: c,
        ),
      );
    }
    setState(() {
      contactWidgets;
    });
  }

  // deletes the friend widget from friendWidgets which holds a friend object that matches the friend argument "f"
  void deleteFriendWidget(Friend f) {
    int fwIndex = -1;
    for (int i = 0; i < friendWidgets.length; ++i) {
      if (friendWidgets[i].friend == f) {
        fwIndex = i;
        break;
      }
    }

    if (fwIndex > 0) {
      friends.remove(f);
      friendWidgets.removeAt(fwIndex);
    }

    setState(() {
      friendWidgets;
    });
  }

  void onRelationshipTypeChange(bool flag) {
    if (flag) {
      selectedRelationshipType = RelationshipTypes.CONTACT;
    } else {
      selectedRelationshipType = RelationshipTypes.FRIEND;
    }

    setAppBarTitleBySelectedRelationshipType();

    setState(() {
      relationshipTypeSwitchFlag = flag;
      selectedRelationshipType;
      friendWidgets;
      contactWidgets;
    });
  }

  Widget? buildFriendWidgets(BuildContext bc, int index) {
    if (index == 0) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: relationshipTypeSwitchFlag,
              onChanged: onRelationshipTypeChange,
              activeColor: Utility.secondaryColor,
              inactiveThumbColor: Utility.secondaryColor,
              inactiveTrackColor: Utility.secondaryColor,
              activeTrackColor: Utility.secondaryColor,
            ),
          ],
        ),
      );
    } else if (friendWidgets.isNotEmpty &&
        index < friendWidgets.length + 1 &&
        selectedRelationshipType == RelationshipTypes.FRIEND) {
      return friendWidgets[index - 1];
    } else if (contactWidgets.isNotEmpty &&
        index < contactWidgets.length + 1 &&
        selectedRelationshipType == RelationshipTypes.CONTACT) {
      return contactWidgets[index - 1];
    }
  }

  void deleteContactWidget(Contact c) {
    int cwIndex = -1;
    for (int i = 0; i < contactWidgets.length; ++i) {
      if (contactWidgets[i].contact == c) {
        cwIndex = i;
        break;
      }
    }

    if (cwIndex > -1) {
      contacts.remove(c);
      contactWidgets.removeAt(cwIndex);
    }

    setState(() {
      contactWidgets;
    });
  }

  void toggleSocialSearchMenu() {
    isSocialSearchMenuVisible = !isSocialSearchMenuVisible;
    if (isSocialSearchMenuVisible) {
      socialSearchMenuIcon = socialSearchMenuIcon = const Icon(
        Icons.keyboard_return,
        color: Utility.secondaryColor,
      );
      setState(() {
        appBarTitle = "Search";
      });
    } else {
      socialSearchMenuIcon = socialSearchMenuIcon = const Icon(
        Icons.search,
        color: Utility.secondaryColor,
      );
      setAppBarTitleBySelectedRelationshipType();
    }
    setState(() {
      socialSearchMenuIcon;
      isSocialSearchMenuVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.primaryColor,
      appBar: AppBar(
        backgroundColor: Utility.primaryColor,
        title: Text(
          appBarTitle,
          style: const TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: toggleSocialSearchMenu,
            icon: Icon(
              socialSearchMenuIcon.icon,
              color: Utility.secondaryColor,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemBuilder: buildFriendWidgets,
          ),
          Visibility(
            visible: isSocialSearchMenuVisible,
            child: SocialSearchMenu(),
          ),
        ],
      ),
    );
  }
}
