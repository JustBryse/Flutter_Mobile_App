import 'package:cao_prototype/pages/dashboard/components/appbar_notification_menu.dart';
import 'package:cao_prototype/pages/dashboard/components/appbar_notification_button.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AssociationInvitationMenu extends StatefulWidget {
  void Function() _disableMenu = () => null;
  AssociationInvitationMenu({Key? key, required void Function() disableMenu})
      : super(key: key) {
    _disableMenu = disableMenu;
  }

  @override
  State<AssociationInvitationMenu> createState() =>
      _AssociationInvitationMenuState();
}

class _AssociationInvitationMenuState extends State<AssociationInvitationMenu> {
  void disableMenu() {
    widget._disableMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Utility.primaryColor,
      child: TextButton(
        onPressed: disableMenu,
        child: const Text(
          "Close Menu",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      ),
    );
  }
}
