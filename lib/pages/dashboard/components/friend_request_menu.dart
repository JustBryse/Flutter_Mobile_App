import 'dart:async';

import 'package:cao_prototype/models/friend_request.dart';
import 'package:cao_prototype/pages/dashboard/components/friend_request_widget.dart';
import 'package:cao_prototype/pages/dashboard/components/unactionable_notification_widget.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class FriendRequestMenu extends StatefulWidget {
  void Function() _disableMenu = () => null;
  Future<void> Function() _updateFriendRequestWidgets = () async {
    return await null;
  };
  List<FriendRequestWidget> _friendRequestWidgets = List.empty(growable: true);
  List<FriendRequestWidget> get friendRequestWidgets => _friendRequestWidgets;
  FriendRequestMenu({
    Key? key,
    required void Function() disableMenu,
    required Future<void> Function() updateFriendRequestWidgets,
    required List<FriendRequestWidget> friendRequestWidgets,
  }) : super(key: key) {
    _disableMenu = disableMenu;
    _updateFriendRequestWidgets = updateFriendRequestWidgets;
    _friendRequestWidgets = friendRequestWidgets;
  }

  @override
  State<FriendRequestMenu> createState() => _FriendRequestMenuState();
}

class _FriendRequestMenuState extends State<FriendRequestMenu> {
  void disableMenu() {
    widget._disableMenu();
  }

  void updateFriendRequestWidgets() async {
    await widget._updateFriendRequestWidgets();
  }

  Widget? buildListViewWidgets(BuildContext bc, int index) {
    if (index == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: disableMenu,
            child: const Text(
              "Back",
              style: TextStyle(
                color: Utility.secondaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: updateFriendRequestWidgets,
            child: const Text(
              "Refresh",
              style: TextStyle(
                color: Utility.secondaryColor,
              ),
            ),
          ),
        ],
      );
    } else if (widget.friendRequestWidgets.isNotEmpty) {
      return widget.friendRequestWidgets[index - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Utility.primaryColor,
      child: ListView.builder(
        itemCount: widget.friendRequestWidgets.length + 1,
        itemBuilder: buildListViewWidgets,
      ),
    );
  }
}
