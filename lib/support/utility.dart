import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

abstract class Utility {
  static const Color primaryColor = Colors.black;
  static const Color primaryColorTranslucent = Color.fromARGB(128, 0, 0, 0);
  static const Color secondaryColor = Colors.white;
  static const Color tertiaryColor = Colors.grey;
  static const double titleFontSize = 40;
  static const double bodyFontSize = 12;

  static displayAlertMessage(
      BuildContext context, String title, String message) {
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              backgroundColor: primaryColor,
              title: Text(
                title,
                style: const TextStyle(color: secondaryColor),
              ),
              content: Text(
                message,
                style: const TextStyle(color: tertiaryColor),
              ),
              actions: [
                IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            )));
  }

  static Future<String> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String deviceName = "";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.utsname.machine;
    }

    return deviceName;
  }

  static Future<String> getApplicationDocumentPath() async {
    Directory applicationDirectory = await getApplicationDocumentsDirectory();
    return applicationDirectory.path;
  }
}
