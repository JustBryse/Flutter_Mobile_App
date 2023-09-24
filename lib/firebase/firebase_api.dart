import 'dart:async';
import 'dart:convert';

import 'package:cao_prototype/support/queries.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// This will cause a push notification to appear in the mobile OS notification tray
Future<void> handleBackgroundMessage(RemoteMessage rm) async {
  if (rm.notification == null) {
    return;
  }
  print("Background Notification -> " +
      rm.notification!.title.toString() +
      ", " +
      rm.notification!.body.toString() +
      ", " +
      rm.data.toString());

  // route to profile page or wherever notifications are
}

// This has no effect on the mobile OS UI. This handler only receives data.
Future<void> handleForegroundMessage(RemoteMessage rm) async {}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>?
      _ssrm; // holds the subscription stream for foreground firebase messages

  // represents the only instantiation of the FirebaseApi class
  static FirebaseApi singleton = FirebaseApi.empty();

  static int _instanceCount = 0;

  FirebaseApi.empty() {
    if (_instanceCount > 0) {
      throw Exception(
        "Error in FirebaseApi.empty(): This class can only be instantiated once.",
      );
    } else {
      _instanceCount++;
    }
  }

  // default constructor
  FirebaseApi() {
    if (_instanceCount > 0) {
      throw Exception(
        "Error in FirebaseApi.empty(): This class can only be instantiated once.",
      );
    } else {
      _instanceCount++;
    }

    initializeNotifications();
    singleton = this;
  }

  // initialize background and foreground messaging functions
  Future<void> initializeNotifications() async {
    await _firebaseMessaging.requestPermission();
    // initialize interrupt-handler functions
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    _ssrm = FirebaseMessaging.onMessage.listen(handleForegroundMessage);
  }

  // get the firebase cloud messaging token that is assigned to the current device
  Future<String> getDeviceToken() async {
    return (await _firebaseMessaging.getToken())!;
  }

  // Add a new function handler for processing foreground firebase messages. Returns a boolean to indicate whether successful.
  bool addForegroundMessageHandler(void Function(RemoteMessage) handler) {
    if (_ssrm == null) {
      return false;
    } else {
      _ssrm!.onData(handler);
      return true;
    }
  }

  /* Expects a remote message where the data attribute is of this format: {data: {...}}, where the data key is a string and its value
     is a dictionary represented as a string. This function returns a map that contains the data arguments. */
  static Map getDecodedNotificationArguments(
    RemoteMessage rm,
  ) {
    if (rm.notification == null) {
      throw Exception(
          "Error in FirebaseApi.getDecodedNotificationArguments(): Remote message notification was null.");
    }

    return Map.of(jsonDecode(rm.data["data"]));
  }
}
