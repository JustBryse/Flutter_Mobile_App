import 'package:cao_prototype/models/friend_request.dart';
import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/pages/components/component_pages/notification_components/friend_request_menu.dart';
import 'package:cao_prototype/pages/components/pageview_selector.dart';

import 'package:cao_prototype/pages/components/component_pages/notification_components/unactionable_notification_widget.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'notification_components/friend_request_widget.dart';

class NotificationPage extends StatefulWidget {
  PageViewSelector _pvs = PageViewSelector.none();

  List<NotificationCodeKeys> _pendingActionableNotificationTypes =
      List.empty(growable: true);
  List<NotificationCodeKeys> get pendingActionableNotificationTypes =>
      _pendingActionableNotificationTypes;
  List<UnactionableNotificationWidget> _unactionableNotificationWidgets =
      List.empty(growable: true);
  List<UnactionableNotificationWidget> get unactionableNotificationWidgets =>
      _unactionableNotificationWidgets;

  NotificationPage({
    Key? key,
    required PageViewSelector pageViewSelector,
    /* Represents the types of notifications that were received. 
    This prepares the notification UI to handle each type of notification. */
    required List<NotificationCodeKeys> pendingActionableNotificationTypes,
    required List<UnactionableNotificationWidget>
        unactionableNotificationWidgets,
  }) : super(key: key) {
    _pvs = pageViewSelector;
    _pendingActionableNotificationTypes = pendingActionableNotificationTypes;
    _unactionableNotificationWidgets = unactionableNotificationWidgets;
  }

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<FriendRequest> friendRequests = List.empty(growable: true);
  List<FriendRequestWidget> friendRequestWidgets = List.empty(growable: true);
  bool isfriendRequestMenuVisible = false;

  Future<void> getFriendRequests() async {
    QueryResult qr = await FriendRequest.getRecipientFriendRequests();
    print(qr.toString());
    if (qr.result == false) {
      return;
    }

    friendRequests.clear();
    friendRequestWidgets.clear();

    for (FriendRequest fr in qr.data) {
      friendRequests.add(fr);
      double width = MediaQuery.of(context).size.width * 0.9;
      friendRequestWidgets.add(
        FriendRequestWidget(
          fr: fr,
          width: width,
          deleteWidget: deleteFriendRequestWidget,
        ),
      );
    }

    setState(() {
      friendRequestWidgets;
    });
  }

  // Called from a friend request widget, this deletes the widget
  void deleteFriendRequestWidget(FriendRequest fr) {
    int index = -1;
    for (int i = 0; i < friendRequestWidgets.length; ++i) {
      if (friendRequestWidgets[i].fr == fr) {
        index = i;
        break;
      }
    }

    if (index > -1) {
      friendRequests.remove(fr);
      setState(() {
        friendRequestWidgets.removeAt(index);
      });
    }
  }

  void enableFriendRequestMenu() async {
    setState(() {
      isfriendRequestMenuVisible = true;
    });
    await getFriendRequests();
    setState(() {
      NotificationManager.friendRequestNotificationIconEnabled = false;
    });
  }

  void disableFriendRequestMenu() {
    setState(() {
      isfriendRequestMenuVisible = false;
    });
  }

  Widget? buildNotificationWidgets(BuildContext, int index) {
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
              Icons.new_releases_outlined,
              color: Utility.secondaryColor,
            ),
          ),
        ],
      );
    } else if (widget.unactionableNotificationWidgets.isNotEmpty &&
        index < widget.unactionableNotificationWidgets.length + 1) {
      return widget.unactionableNotificationWidgets[index - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.primaryColor,
      appBar: AppBar(
        backgroundColor: Utility.primaryColor,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemBuilder: buildNotificationWidgets,
          ),
          Visibility(
            visible: isfriendRequestMenuVisible,
            child: FriendRequestMenu(
              disableMenu: disableFriendRequestMenu,
              updateFriendRequestWidgets: getFriendRequests,
              friendRequestWidgets: friendRequestWidgets,
            ),
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
