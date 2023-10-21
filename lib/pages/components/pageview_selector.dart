import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class PageViewSelector extends StatefulWidget {
  void Function() _jumpToMessages = () {
    return;
  };

  void Function() _jumpToNotifications = () {
    return;
  };

  void Function() _jumpToPageFromNavigationPathway = () {
    return;
  };

  Icon _notificationButtonIcon = const Icon(
    Icons.notifications,
    color: Utility.primaryColor,
  );
  Icon get notificationButtonIcon => _notificationButtonIcon;

  Icon _messageButtonIcon = const Icon(
    Icons.mail,
    color: Utility.primaryColor,
  );

  Icon get messageButtonIcon => _messageButtonIcon;

  PageViewSelector.all({
    Key? key,
    required void Function() jumpToMessages,
    required void Function() jumpToNotifications,
    required void Function() jumpToPageFromNavigationPathway,
    required Icon notificationButtonIcon,
    required Icon messageButtonIcon,
  }) : super(key: key) {
    _jumpToMessages = jumpToMessages;
    _jumpToNotifications = jumpToNotifications;
    _jumpToPageFromNavigationPathway = jumpToPageFromNavigationPathway;
    _notificationButtonIcon = notificationButtonIcon;
    _messageButtonIcon = messageButtonIcon;
  }

  PageViewSelector.none();

  @override
  State<PageViewSelector> createState() => _PageViewSelectorState();
}

class _PageViewSelectorState extends State<PageViewSelector> {
  void jumpToMessages() {
    widget._jumpToMessages();
  }

  void jumpToNotifications() {
    widget._jumpToNotifications();
  }

  // jumps to a page from the UI navigation structure of the application
  void jumpToPageFromNavigationPathway() {
    widget._jumpToPageFromNavigationPathway();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      color: Utility.tertiaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: jumpToMessages,
            icon: Icon(
              widget.messageButtonIcon.icon,
              color: Utility.primaryColor,
            ),
          ),
          IconButton(
            onPressed: jumpToPageFromNavigationPathway,
            icon: const Icon(
              Icons.center_focus_strong,
              color: Utility.primaryColor,
            ),
          ),
          IconButton(
            onPressed: jumpToNotifications,
            icon: Icon(
              widget.notificationButtonIcon.icon,
              color: Utility.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
