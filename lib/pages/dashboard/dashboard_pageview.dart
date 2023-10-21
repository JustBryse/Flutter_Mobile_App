import 'package:cao_prototype/firebase/firebase_api.dart';
import 'package:cao_prototype/notifications/models/unactionable_notification.dart';
import 'package:cao_prototype/notifications/notification_manager.dart';
import 'package:cao_prototype/pages/components/component_pages/notifications.dart';
import 'package:cao_prototype/pages/components/pageview_selector.dart';
import 'package:cao_prototype/pages/components/component_pages/notification_components/unactionable_notification_widget.dart';
import 'package:cao_prototype/pages/dashboard/dashboard.dart';

import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../components/component_pages/messages.dart';

class DashboardPageView extends StatefulWidget {
  const DashboardPageView({super.key});

  @override
  State<DashboardPageView> createState() => _DashboardPageViewState();
}

class _DashboardPageViewState extends State<DashboardPageView>
    with WidgetsBindingObserver {
  // PAGEVIEW NAVIGATION FUNCTIONS & VARIABLES FOLLOW -------------------------------------------------

  PageController pc = PageController(initialPage: 1);

  void jumpToMessages() {
    pc.jumpToPage(0);
  }

  void jumpToNotifications() {
    setNotificationIconToInactive();
    pc.jumpToPage(2);
  }

  void jumpToPageFromNavigationPathway() {
    pc.jumpToPage(1);
  }

  // FIREBASE FUNCTIONS & VARIABLES FOLLOW ----------------------------------------------------------------

  /* Contains a code for each type of unactionable or actionable notification that has been received so the notification page
  UI can prepare to accomodate each type and alert the user properly. */
  List<NotificationCodeKeys> pendingActionableNotificationTypes =
      List.empty(growable: true);
  // stores the unactionable notification widgets that feed into the notification page
  List<UnactionableNotificationWidget> unactionableNotificationWidgets =
      List.empty(growable: true);

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

  Icon notificationButtonIcon = const Icon(
    Icons.notifications,
    color: Utility.primaryColor,
  );

  Icon messageButtonIcon = const Icon(
    Icons.mail,
    color: Utility.primaryColor,
  );

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
      setNotificationIconToActive();
      pendingActionableNotificationTypes.clear();
      setState(() {
        pendingActionableNotificationTypes = qr.data;
      });
    }
  }

  // when this page's state resumes, import any firebase messages that came in while the app was in the background
  Future<void> handleBackgroundUnactionableNotificationsOnResumeState() async {
    // This simply adds notifications that were received in the background to the unactionableNotifications list
    QueryResult qr =
        await NotificationManager.importBackgroundUnactionableNotifications();
    if (qr.result && qr.data) {
      setNotificationIconToActive();
      setUnactionableNotificationWidgets();
    }
  }

  // listener function for incoming foreground firebase messages
  void handleForegroundFirebaseMessage(RemoteMessage rm) {
    if (rm.notification == null) {
      return;
    }

    Map arguments = FirebaseApi.getDecodedNotificationArguments(rm);

    NotificationCodeKeys notificationKey =
        NotificationCodes.getCodeKey(arguments["notification_code"]);

    UnactionableNotification? un =
        NotificationManager.handleForegroundNotification(rm);

    if (un != null) {
      // if it was a valid notification, then activate the notification icon
      setNotificationIconToActive();
      // if the received notification was unactionable, then update the unactionable notification widgets
      if (un.type == NotificationCodeKeys.FRIEND_REQUEST_RESPONSE ||
          un.type == NotificationCodeKeys.NONE) {
        setUnactionableNotificationWidgets();
      }
    }
  }

  // updates the unactionable notification widgets
  void setUnactionableNotificationWidgets() {
    unactionableNotificationWidgets.clear();
    for (UnactionableNotification un
        in NotificationManager.unactionableNotifications) {
      double width = MediaQuery.of(context).size.width * 0.9;
      unactionableNotificationWidgets.add(
        UnactionableNotificationWidget(
          width: width,
          un: un,
          deleteNotification: deleteUnactionableNotification,
        ),
      );
    }

    setState(() {
      unactionableNotificationWidgets;
    });
  }

  // Allows an unactionable notification to be deleted. This function should be called on the widget being deleted.
  bool deleteUnactionableNotification(UnactionableNotification un) {
    int index = -1;
    for (int i = 0; i < unactionableNotificationWidgets.length; ++i) {
      if (unactionableNotificationWidgets[i].un == un) {
        index = i;
        break;
      }
    }

    if (index > -1) {
      setState(() {
        unactionableNotificationWidgets.removeAt(index);
      });
      NotificationManager.unactionableNotifications.remove(un);
      return true;
    } else {
      return false;
    }
  }

  void setNotificationIconToActive() {
    // change the icon appearance of this widget to inform the user of the notification
    setState(
      () {
        notificationButtonIcon = const Icon(
          Icons.notifications_active,
          color: Utility.primaryColorTranslucent,
        );
      },
    );
  }

  void setNotificationIconToInactive() {
    setState(
      () {
        notificationButtonIcon = const Icon(
          Icons.notifications,
          color: Utility.primaryColorTranslucent,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics:
          ScrollPhysics(), // WIP -> create custom scroll physics to prevent horizontal swiping
      controller: pc,
      children: [
        MessagePage(
          pvs: PageViewSelector.all(
            jumpToMessages: jumpToMessages,
            jumpToNotifications: jumpToNotifications,
            jumpToPageFromNavigationPathway: jumpToPageFromNavigationPathway,
            notificationButtonIcon: notificationButtonIcon,
            messageButtonIcon: messageButtonIcon,
          ),
        ),
        DashboardPage(
          pvs: PageViewSelector.all(
            jumpToMessages: jumpToMessages,
            jumpToNotifications: jumpToNotifications,
            jumpToPageFromNavigationPathway: jumpToPageFromNavigationPathway,
            notificationButtonIcon: notificationButtonIcon,
            messageButtonIcon: messageButtonIcon,
          ),
        ),
        NotificationPage(
          pageViewSelector: PageViewSelector.all(
            jumpToMessages: jumpToMessages,
            jumpToNotifications: jumpToNotifications,
            jumpToPageFromNavigationPathway: jumpToPageFromNavigationPathway,
            notificationButtonIcon: notificationButtonIcon,
            messageButtonIcon: messageButtonIcon,
          ),
          pendingActionableNotificationTypes:
              pendingActionableNotificationTypes,
          unactionableNotificationWidgets: unactionableNotificationWidgets,
        ),
      ],
    );
  }
}
