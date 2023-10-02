import 'dart:convert';

import 'package:cao_prototype/firebase/firebase_api.dart';
import 'package:cao_prototype/pages/dashboard/components/unactionable_notification_widget.dart';
import 'package:cao_prototype/pages/dashboard/profile/profile.dart';
import 'package:cao_prototype/pages/dashboard/profile/social/social.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AppBarNotificationButton extends StatefulWidget {
  void Function(bool) _toggleProfileMenu = (argument) {};
  // optional function
  void Function(RemoteMessage)? _firebaseForegroundMessageHandler;
  void Function() _refreshUnactionableNotificationWidgets = () {};
  void Function(List<NotificationCodeKeys>)
      _enableActionableNotificationMenuIcons = (ncks) {};

  AppBarNotificationButton({
    Key? key,
    required void Function(bool) toggleProfileMenu,
    // optional function argument if parent-widget wants to listen for firebase messages
    void Function(RemoteMessage)? firebaseForegroundMessageHandler,
    required void Function() refreshUnactionableNotificationWidgets,
    required void Function(List<NotificationCodeKeys>)
        enableActionableNotificationMenuIcons,
  }) : super(key: key) {
    _toggleProfileMenu = toggleProfileMenu;
    _firebaseForegroundMessageHandler = firebaseForegroundMessageHandler;
    _refreshUnactionableNotificationWidgets =
        refreshUnactionableNotificationWidgets;
    _enableActionableNotificationMenuIcons =
        enableActionableNotificationMenuIcons;
  }

  @override
  State<AppBarNotificationButton> createState() =>
      _AppBarNotificationButtonState();
}

class _AppBarNotificationButtonState extends State<AppBarNotificationButton>
    with WidgetsBindingObserver {
  bool isProfileMenuVisible = false;
  Icon accountButtonIcon = const Icon(Icons.notifications_none_rounded);

  @override
  void initState() {
    // initialize firebase foreground message handler
    FirebaseApi.singleton.addForegroundMessageHandler(
      handleForegroundFirebaseMessage,
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    /* Check background notifications when this widget starts. This is going to happen mostly when the app is started up
    and the dashboard page is pushed to the page stack (along with this widget) during automatic login. This event could 
    occur when the user presses the CAO notification button in their mobile OS notification tray and thus opens this app 
    from being previously inactive. */
    handleBackgroundNotificationsOnResumeState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleState.resumed == state) {
      handleBackgroundNotificationsOnResumeState();
    }
  }

  /* Top level function that is responsible for processing notifications that were received in the background state and saved
  in the front-end sql database. */
  void handleBackgroundNotificationsOnResumeState() async {
    await handleBackgroundUnactionableNotificationsOnResumeState();
    await handleBackgroundActionableNotificationsOnResumeState();
    await NotificationManager.deleteBackgroundNotifications();
  }

  /* When the page opens, check if any actionable notifications were received while in the background state.
     If so, simply change the notification icons/buttons that corrospond to the actionable notification sections
     of the notification menu. This will alert the user that actionable notifications were recieved, and then
     they can manually query the server for friend requests, association invitations, etcetera. */
  Future<void> handleBackgroundActionableNotificationsOnResumeState() async {
    QueryResult qr = await NotificationManager
        .importBackgroundActionableNotificationCodeKeys();

    if (qr.result == false) {
      return;
    }

    // update the notification menu to show a new actionable notification is pending
    if (qr.data.isNotEmpty) {
      updateNotificationIconState();
      widget._enableActionableNotificationMenuIcons(qr.data);
    }
  }

  // when this page's state resumes, import any firebase messages that came in while the app was in the background
  Future<void> handleBackgroundUnactionableNotificationsOnResumeState() async {
    // This simply adds notifications that were received in the background to the unactionableNotifications list
    QueryResult qr =
        await NotificationManager.importBackgroundUnactionableNotifications();
    if (qr.result && qr.data) {
      updateNotificationIconState();
      widget._refreshUnactionableNotificationWidgets();
    }
  }

  // listener function for incoming firebase messages
  void handleForegroundFirebaseMessage(RemoteMessage rm) {
    if (rm.notification == null) {
      return;
    }

    Map arguments = FirebaseApi.getDecodedNotificationArguments(rm);

    NotificationCodeKeys notificationKey =
        NotificationCodes.getCodeKey(arguments["notification_code"]);

    updateNotificationIconState();

    // call the parent-widget listener function to pass on RemoteMessage data
    if (widget._firebaseForegroundMessageHandler != null) {
      widget._firebaseForegroundMessageHandler!(rm);
    }
  }

  void updateNotificationIconState() {
    // change the icon appearance of this widget to inform the user of the notification
    setState(
      () {
        accountButtonIcon = const Icon(
          Icons.notifications_active_rounded,
          color: Utility.primaryColorTranslucent,
        );
      },
    );
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
