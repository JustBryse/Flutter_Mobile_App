import 'dart:convert';

import 'package:cao_prototype/firebase/firebase_api.dart';
import 'package:cao_prototype/pages/dashboard/components/unactionable_notification_widget.dart';
import 'package:cao_prototype/pages/dashboard/profile/profile.dart';
import 'package:cao_prototype/pages/dashboard/profile/social/social.dart';
import 'package:cao_prototype/support/notification_manager.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AppBarNotificationButton extends StatefulWidget {
  void Function(bool) _toggleProfileMenu = (argument) => null;
  // optional function
  void Function(RemoteMessage)? _firebaseForegroundMessageHandler;

  AppBarNotificationButton({
    Key? key,
    required void Function(bool) toggleProfileMenu,
    // optional function argument if parent-widget wants to listen for firebase messages
    void Function(RemoteMessage)? firebaseForegroundMessageHandler,
  }) : super(key: key) {
    _toggleProfileMenu = toggleProfileMenu;
    _firebaseForegroundMessageHandler = firebaseForegroundMessageHandler;
  }

  @override
  State<AppBarNotificationButton> createState() =>
      _AppBarNotificationButtonState();
}

class _AppBarNotificationButtonState extends State<AppBarNotificationButton> {
  bool isProfileMenuVisible = false;
  Icon accountButtonIcon = const Icon(Icons.notifications_none_rounded);

  @override
  void initState() {
    // initialize firebase foreground message handler
    FirebaseApi.singleton.addForegroundMessageHandler(
      handleForegroundFirebaseMessage,
    );
  }

  // listener function for incoming firebase messages
  void handleForegroundFirebaseMessage(RemoteMessage rm) {
    if (rm.notification == null) {
      return;
    }

    Map arguments = FirebaseApi.getDecodedNotificationArguments(rm);

    NotificationCodeKeys notificationKey =
        NotificationCodes.getCodeKey(arguments["notification_code"]);

    // change the icon appearance of this widget to inform the user of the notification
    if (notificationKey == NotificationCodeKeys.NONE ||
        notificationKey == NotificationCodeKeys.FRIEND_REQUEST ||
        notificationKey == NotificationCodeKeys.FRIEND_REQUEST_RESPONSE ||
        notificationKey == NotificationCodeKeys.ASSOCIATION_INVITATION) {
      setState(() {
        accountButtonIcon = const Icon(
          Icons.notifications_active_rounded,
          color: Utility.primaryColorTranslucent,
        );
      });
    }

    // call the parent-widget listener function to pass on RemoteMessage data
    if (widget._firebaseForegroundMessageHandler != null) {
      widget._firebaseForegroundMessageHandler!(rm);
    }
  }

  void toggleProfileMenu() {
    isProfileMenuVisible = !isProfileMenuVisible;
    widget._toggleProfileMenu(isProfileMenuVisible);

    // reset the account button menu to its unnotified appearance
    setState(() {
      accountButtonIcon = const Icon(
        Icons.notifications_none_rounded,
        color: Utility.secondaryColor,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: toggleProfileMenu,
      icon: Icon(
        accountButtonIcon.icon,
        color: Utility.secondaryColor,
      ),
    );
  }
}
