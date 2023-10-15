import 'package:cao_prototype/models/contact.dart';
import 'package:cao_prototype/models/structures/user_profile.dart';
import 'package:cao_prototype/pages/dashboard/profile/external_profile.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ContactWidget extends StatefulWidget {
  double _width = -1;
  double get width => _width;
  Contact _contact = Contact.none();
  Contact get contact => _contact;
  // tells the social page to refresh friends and contact data
  void Function() _getFriendsAndContacts = () {};

  ContactWidget({
    Key? key,
    required double width,
    required Contact contact,
    required void Function() getFriendsAndContacts,
  }) : super(key: key) {
    _width = width;
    _contact = contact;
    _getFriendsAndContacts = getFriendsAndContacts;
  }

  @override
  State<ContactWidget> createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  void navigateToExternalProfilePage() async {
    QueryResult qr = await UserProfile.getUserProfile(
      Session.currentUser.id,
      widget.contact.contactedId,
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
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.person_rounded,
                    color: Utility.primaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    "${widget.contact.contacted.alias} (#${widget.contact.contacted.id})",
                    style: const TextStyle(
                      color: Utility.primaryColor,
                    ),
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
