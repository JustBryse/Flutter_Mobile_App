import 'package:cao_prototype/models/structures/user_profile.dart';
import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/pages/dashboard/profile/external_profile.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class UserWidget extends StatefulWidget {
  User _user = User.none();
  User get user => _user;
  double _width = -1;
  double get width => _width;
  void Function() _getFriendsAndContacts = () {};
  UserWidget({
    Key? key,
    required User user,
    required double width,
    required void Function() getFriendsAndContacts,
  }) : super(key: key) {
    _user = user;
    _width = width;
    _getFriendsAndContacts = getFriendsAndContacts;
  }

  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  void navigateToExternalProfilePage() async {
    QueryResult qr = await UserProfile.getUserProfile(
      Session.currentUser.id,
      widget.user.id,
    );

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "User Profile Error", "Failed to get user profile.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExternalProfilePage(
          userProfile: qr.data,
        ),
      ),
    ).then((value) => widget._getFriendsAndContacts());
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: IconButton(
                    onPressed: navigateToExternalProfilePage,
                    icon: const Icon(
                      Icons.home,
                      color: Utility.primaryColor,
                    ),
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
