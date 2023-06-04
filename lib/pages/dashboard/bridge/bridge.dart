import 'package:cao_prototype/pages/dashboard/bridge/components/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/pages/dashboard/navigation.dart';

class DashboardBridge extends StatefulWidget {
  PageController _pageController = PageController();

  DashboardBridge({Key? key, required PageController pc}) : super(key: key) {
    _pageController = pc;
  }

  @override
  State<DashboardBridge> createState() =>
      _DashboardBridgeState(_pageController);
}

class _DashboardBridgeState extends State<DashboardBridge> {
  PageController _pageController = PageController();

  _DashboardBridgeState(PageController pc) {
    _pageController = pc;
  }

  // this TEC is associated to the text input box where the user enters their chatbot question
  TextEditingController chatbotQueryTEC = TextEditingController();
  // holds a list of message bubble UI components
  List<MessageBubble> messageBubbles = List.empty(growable: true);

  void initializeMessageBubbles() {
    messageBubbles.clear();
    for (int i = 0; i < 20; ++i) {
      String message =
          "Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message Message: $i";
      bool isChatbotMessage = true;

      if (i % 2 == 0) {
        isChatbotMessage = false;
      }
      MessageBubble mb =
          MessageBubble(message: message, isChatbotMessage: isChatbotMessage);
      messageBubbles.add(mb);
    }
    setState(() {
      messageBubbles;
    });
  }

  void sendMessage() {
    String userMessage = chatbotQueryTEC.text;
  }

  @override
  Widget build(BuildContext context) {
    initializeMessageBubbles();
    return Scaffold(
      backgroundColor: Utility.secondaryColor,
      appBar: AppBar(
        actions: [
          DashboardNavigationRow.all(pc: _pageController),
        ],
        title: const Text(
          "Bridge",
          style: TextStyle(
            fontSize: Utility.titleFontSize,
            color: Utility.secondaryColor,
          ),
        ),
        backgroundColor: Utility.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (index < messageBubbles.length) {
                  return messageBubbles[index];
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Utility.primaryColorTranslucent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: TextField(
                    cursorColor: Utility.primaryColor,
                    cursorWidth: 1,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Utility.primaryColor),
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

      /*floatingActionButton: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          DashboardNavigationRow.all(pc: _pageController),
        ],
      ),*/
    );
  }
}
