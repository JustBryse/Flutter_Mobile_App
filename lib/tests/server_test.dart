import 'package:cao_prototype/support/server.dart';
import 'package:flutter/material.dart';

class ServerTestPage extends StatefulWidget {
  const ServerTestPage({super.key});

  @override
  State<ServerTestPage> createState() => _ServerTestPageState();
}

class _ServerTestPageState extends State<ServerTestPage> {
  TextEditingController testTEC = TextEditingController();
  String responseText = "";

  sendWebServerRequest() async {
    Map<String, String> arguments = {"data": testTEC.text};
    var response = await Server.submitGetRequest(arguments, "chatbot/request");
    setState(() {
      responseText = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(controller: testTEC),
          TextButton(
            onPressed: sendWebServerRequest,
            child: const Text("Submit"),
          ),
          Text(responseText),
        ],
      ),
    );
  }
}
