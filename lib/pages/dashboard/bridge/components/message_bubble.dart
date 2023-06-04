import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MessageBubble extends StatefulWidget {
  String _message = "";
  bool _isChatbotMessage = false;

  MessageBubble(
      {Key? key, required String message, required bool isChatbotMessage})
      : super(key: key) {
    _message = message;
    _isChatbotMessage = isChatbotMessage;
  }

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  TextEditingController bubbleTextTEC = TextEditingController();
  MainAxisAlignment bubbleAlignment = MainAxisAlignment.center;
  TextAlign bubbleTextAlignment = TextAlign.center;
  Color bubbleColor = Colors.black;
  Color bubbleTextColor = Colors.black;

  void initializeMessageBubble() {
    if (widget._isChatbotMessage) {
      bubbleAlignment = MainAxisAlignment.start;
      bubbleTextAlignment = TextAlign.start;
      bubbleColor = Utility.tertiaryColor;
      bubbleTextColor = Utility.primaryColor;
    } else {
      bubbleAlignment = MainAxisAlignment.end;
      bubbleTextAlignment = TextAlign.end;
      bubbleColor = Utility.primaryColorTranslucent;
      bubbleTextColor = Utility.primaryColor;
    }
    bubbleTextTEC.text = widget._message;
  }

  @override
  Widget build(BuildContext context) {
    initializeMessageBubble();
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: bubbleColor,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: bubbleAlignment,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TextField(
              style: TextStyle(color: bubbleTextColor),
              textAlignVertical: TextAlignVertical.top,
              textAlign: bubbleTextAlignment,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabled: false,
                contentPadding: EdgeInsets.all(4),
              ),
              controller: bubbleTextTEC,
              readOnly: true,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}
