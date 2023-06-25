import 'package:cao_prototype/models/university.dart';
import 'package:cao_prototype/pages/dashboard/bridge/components/message_bubble.dart';
import 'package:cao_prototype/support/chatbot.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';

class DashboardBridge extends StatefulWidget {
  const DashboardBridge({super.key});

  @override
  State<DashboardBridge> createState() => _DashboardBridgeState();
}

class _DashboardBridgeState extends State<DashboardBridge> {
  // this TEC is associated to the text input box where the user enters their chatbot question
  TextEditingController chatbotQueryTEC = TextEditingController();
  // holds a list of message bubble UI components
  List<MessageBubble> messageBubbles = List.empty(growable: true);
  // holds the universities that the user can choose to ask questions about
  List<DropdownMenuEntry<University>> universityDropdownButtons =
      List.empty(growable: true);
  // holds the currently selected university that the user can ask questions about
  University selectedUniversity = University.none();
  // used to indicate the state of loading or fetching information from the server
  bool isLoading = false;
  bool lockUserInterface = false;

  @override
  void initState() {
    super.initState();
    fetchUniversities();
  }

  // fetch university data for the university dropdown list
  void fetchUniversities() async {
    setState(() {
      isLoading = true;
    });

    QueryResult qr = await University.getUniversities();

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "Failed to Fetch Data", "Please try again.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    universityDropdownButtons.clear();

    for (University university in qr.data) {
      universityDropdownButtons.add(
        DropdownMenuEntry<University>(
          value: university,
          label: university.getName(),
        ),
      );

      setState(() {
        universityDropdownButtons;
        selectedUniversity = universityDropdownButtons[0].value;
        isLoading = false;
      });
    }
  }

  // allows the user to select the university that they want to ask questions about
  void selectUniversity(University? university) {
    if (university == null) {
      return;
    }
    selectedUniversity = university;
  }

  // sends messages to the chatbot
  void sendMessage() async {
    // abort conditions
    if (chatbotQueryTEC.text.isEmpty) {
      return;
    }

    setState(() {
      lockUserInterface = true;
    });

    // send message to chatbot on the back end server
    QueryResult qr = await ChatbotQueries.queryChatbot(Session.currentUser.id,
        selectedUniversity.getId(), chatbotQueryTEC.text);

    if (qr.result) {
      // this is for UI testing only, proper request will be made to the server later
      messageBubbles.add(
        MessageBubble(message: chatbotQueryTEC.text, isChatbotMessage: false),
      );
      messageBubbles.add(
        MessageBubble(message: qr.data["response"], isChatbotMessage: true),
      );

      setState(() {
        chatbotQueryTEC.text = "";
        messageBubbles;
      });
    } else {
      Utility.displayAlertMessage(
          context, "Failed to Send Message", "Please try again.");
    }

    setState(() {
      lockUserInterface = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.secondaryColor,
      appBar: AppBar(
        title: const Text(
          "Bridge",
          style: TextStyle(
            fontSize: Utility.titleFontSize,
            color: Utility.secondaryColor,
          ),
        ),
        backgroundColor: Utility.primaryColor,
      ),
      body: isLoading
          ? Container(
              color: Utility.primaryColor,
              child: const Center(
                child: Text(
                  "Fetching Data. Please wait.",
                  style: TextStyle(fontSize: 20, color: Utility.secondaryColor),
                ),
              ),
            )
          : AbsorbPointer(
              absorbing: lockUserInterface,
              child: Column(
                children: [
                  // dropdown university menu
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Utility.tertiaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        DropdownMenu(
                          menuStyle: MenuStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Utility.tertiaryColor),
                          ),
                          width: MediaQuery.of(context).size.width * 0.5,
                          leadingIcon: const Icon(
                            Icons.school,
                            color: Utility.primaryColor,
                          ),
                          trailingIcon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Utility.primaryColor,
                          ),
                          initialSelection: selectedUniversity,
                          dropdownMenuEntries: universityDropdownButtons,
                          onSelected: selectUniversity,
                        ),
                      ],
                    ),
                  ),
                  // message bubble list
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if (index < messageBubbles.length) {
                          return messageBubbles[index];
                        }
                      },
                    ),
                  ),
                  // message input form
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Utility.tertiaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextField(
                            cursorColor: Utility.primaryColor,
                            cursorWidth: 1,
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Utility.primaryColor),
                              ),
                            ),
                            controller: chatbotQueryTEC,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        IconButton(
                          onPressed: sendMessage,
                          icon: const Icon(
                            Icons.send,
                            color: Utility.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
