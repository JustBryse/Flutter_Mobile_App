import 'package:flutter/material.dart';

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
}
