import 'package:cao_prototype/firebase/firebase_api.dart';
import 'package:cao_prototype/models/friend_request.dart';
import 'package:cao_prototype/pages/dashboard/components/association_invitation_menu.dart';
import 'package:cao_prototype/pages/dashboard/components/friend_request_menu.dart';
import 'package:cao_prototype/pages/dashboard/components/friend_request_widget.dart';
import 'package:cao_prototype/pages/dashboard/components/unactionable_notification_widget.dart';
import 'package:cao_prototype/pages/dashboard/profile/profile.dart';
import 'package:cao_prototype/pages/dashboard/profile/social/social.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AppBarNotificationMenu extends StatefulWidget {
  double _notificationWidth = -1;
  double get notificationWidth => _notificationWidth;

  List<UnactionableNotificationWidget> _unactionableNotificationWidgets =
      List.empty(growable: true);

  List<UnactionableNotificationWidget> get unactionableNotificationWidgets =>
      _unactionableNotificationWidgets;

  // the notification icons in this widget are controlled by booleans in the parent widget
  AppBarNotificationMenu({
    Key? key,
    required double notificationWidth,
    required List<UnactionableNotificationWidget>
        unactionableNotificationWidgets,
  }) : super(key: key) {
    _notificationWidth = notificationWidth;
    _unactionableNotificationWidgets = unactionableNotificationWidgets;
  }

  @override
  State<AppBarNotificationMenu> createState() => _AppBarNotificationMenuState();
}

class _AppBarNotificationMenuState extends State<AppBarNotificationMenu> {
  bool isFriendRequestMenuVisible = false;
  bool isAssociationInvitationMenuVisible = false;

  List<FriendRequest> friendRequests = List.empty(growable: true);
  List<FriendRequestWidget> friendRequestWidgets = List.empty(growable: true);

  Future<void> getFriendRequests() async {
    QueryResult qr = await FriendRequest.getRecipientFriendRequests();

    if (qr.result == false) {
      Utility.displayAlertMessage(
        context,
        "Friend Requests Unavailable",
        "Failed to fetch friend requests.",
      );
      return;
    }

    friendRequests.clear();
    friendRequestWidgets.clear();

    for (FriendRequest fr in qr.data) {
      friendRequests.add(fr);
      friendRequestWidgets.add(
        FriendRequestWidget(
          fr: fr,
          width: widget.notificationWidth,
        ),
      );
    }

    setState(() {
      friendRequests;
      friendRequestWidgets;
    });
  }

  void enableFriendRequestMenu() async {
    disableNotificationIcon(NotificationCodeKeys.FRIEND_REQUEST);
    // fetch friend requests before opening the friend request menu
    await getFriendRequests();
    setState(() {
      isFriendRequestMenuVisible = true;
    });
  }

  void enableAssociationInvitationMenu() {
    disableNotificationIcon(NotificationCodeKeys.ASSOCIATION_INVITATION);
    setState(() {
      isAssociationInvitationMenuVisible = true;
    });
  }

  void disableAssociationInvitationMenu() {
    setState(() {
      isAssociationInvitationMenuVisible = false;
    });
  }

  void disableFriendRequestMenu() {
    setState(() {
      isFriendRequestMenuVisible = false;
    });
  }

  void disableNotificationIcon(NotificationCodeKeys notificationType) {
    // pending friend request
    if (notificationType == NotificationCodeKeys.FRIEND_REQUEST) {
      setState(() {
        NotificationManager.friendRequestNotificationIconEnabled = false;
      });
    }
    // new friend notification
    else if (notificationType == NotificationCodeKeys.ASSOCIATION_INVITATION) {
      setState(() {
        NotificationManager.associationInvitationNotificationIconEnabled =
            false;
      });
    }
  }

  Widget? buildListViewWidgets(BuildContext bc, int index) {
    // first, return the friend requests button
    if (index == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: enableFriendRequestMenu,
            child: const Text(
              "Friend Requests",
              style: TextStyle(color: Utility.secondaryColor),
            ),
          ),
          Visibility(
            visible: NotificationManager.friendRequestNotificationIconEnabled,
            child: const Icon(
              Icons.notification_add_rounded,
              color: Utility.secondaryColor,
            ),
          ),
        ],
      );
      // second, return the association invitations button
    } else if (index == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: enableAssociationInvitationMenu,
            child: const Text(
              "Association Invitations",
              style: TextStyle(color: Utility.secondaryColor),
            ),
          ),
          Visibility(
            visible: NotificationManager
                .associationInvitationNotificationIconEnabled,
            child: const Icon(
              Icons.notification_add_rounded,
              color: Utility.secondaryColor,
            ),
          ),
        ],
      );
      // return all unactionable notification widgets
    } else if (widget.unactionableNotificationWidgets.isNotEmpty) {
      return widget.unactionableNotificationWidgets[index - 2];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Utility.primaryColor,
      child: Stack(
        children: [
          // populates the notification menu with menu buttons and unactionable notifications
          ListView.builder(
            itemCount: widget.unactionableNotificationWidgets.length + 2,
            itemBuilder: buildListViewWidgets,
          ),
          Visibility(
            visible: isFriendRequestMenuVisible,
            child: FriendRequestMenu(
              disableMenu: disableFriendRequestMenu,
              friendRequestWidgets: friendRequestWidgets,
              updateFriendRequestWidgets: getFriendRequests,
            ),
          ),
          Visibility(
            visible: isAssociationInvitationMenuVisible,
            child: AssociationInvitationMenu(
              disableMenu: disableAssociationInvitationMenu,
            ),
          ),
        ],
      ),
    );
  }
}
