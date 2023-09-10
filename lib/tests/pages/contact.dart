import 'package:cao_prototype/models/contact.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ContactUnitTestPage extends StatefulWidget {
  const ContactUnitTestPage({super.key});

  @override
  State<ContactUnitTestPage> createState() => _ContactUnitTestPageState();
}

class _ContactUnitTestPageState extends State<ContactUnitTestPage> {
  void getContacts() async {
    QueryResult qr = await Contact.getContacts();

    if (qr.result == false) {
      Utility.displayAlertMessage(
        context,
        "Failure Result",
        "Result Code: " +
            ResultCodes.getCodeKey(qr.resultCode).name +
            ".\nMessage: " +
            qr.message,
      );
      return;
    }

    for (Contact c in qr.data) {
      print(c.toString() + "\n");
    }

    Utility.displayAlertMessage(context, "Success Result", "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text(
          "Contact Unit Test Page",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          color: Colors.blue,
          child: TextButton(
            onPressed: getContacts,
            child: const Text(
              "Get Contacts",
              style: TextStyle(
                color: Utility.secondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
