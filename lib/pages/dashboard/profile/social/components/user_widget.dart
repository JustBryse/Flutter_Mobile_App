import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class UserWidget extends StatefulWidget {
  void Function(User) _deleteWidget = (p0) {};
  User _user = User.none();
  User get user => _user;
  double _width = -1;
  double get width => _width;
  UserWidget({
    Key? key,
    required Function(User) deleteWidget,
    required User user,
    required double width,
  }) : super(key: key) {
    _deleteWidget = deleteWidget;
    _user = user;
    _width = width;
  }

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  void navigateToUserProfilePage() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        width: widget.width,
        decoration: const BoxDecoration(
          color: Utility.tertiaryColor,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.person,
                    color: Utility.primaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    "${widget.user.alias} (#${widget.user.id})",
                    style: const TextStyle(color: Utility.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
