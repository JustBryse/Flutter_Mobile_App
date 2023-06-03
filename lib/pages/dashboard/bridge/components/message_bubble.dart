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

  @override
  Widget build(BuildContext context) {
    bubbleTextTEC.text = widget._message;
    return Container(
      decoration: BoxDecoration(
        color: Utility.tertiaryColor,
        border: Border.all(color: Utility.primaryColor),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (widget._isChatbotMessage)
            const Icon(
              Icons.android,
              color: Utility.secondaryColor,
            ),
          if (!widget._isChatbotMessage)
            const Icon(
              Icons.account_box,
              color: Utility.secondaryColor,
            ),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
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
