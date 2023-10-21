import 'package:cao_prototype/firebase/firebase_api.dart';
import 'package:cao_prototype/pages/dashboard/bridge/bridge.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/create_thread.dart';
import 'package:cao_prototype/pages/home.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/tests/miscellaneous/carousel%20slider/page_carousel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/pages/globe.dart';
import 'package:cao_prototype/pages/splash.dart';
import 'package:cao_prototype/pages/dashboard/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initializeNotifications();
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
}
