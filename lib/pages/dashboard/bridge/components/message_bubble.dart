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
      bubbleColor = Utility.tertiaryColor;
      bubbleTextColor = Utility.secondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeMessageBubble();
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: bubbleAlignment,
        children: [
          Container(
            constraints: BoxConstraints(
                maxHeight: double.maxFinite,
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(1, 0, 0, 0)),
              color: bubbleColor,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              widget._message,
              textAlign: bubbleTextAlignment,
              maxLines: null,
              style: TextStyle(color: bubbleTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
