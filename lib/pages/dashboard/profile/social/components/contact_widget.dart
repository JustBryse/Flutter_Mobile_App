import 'package:cao_prototype/models/contact.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ContactWidget extends StatefulWidget {
  double _width = -1;
  double get width => _width;
  Contact _contact = Contact.none();
  Contact get contact => _contact;

  void Function(Contact) _deleteWidget = (p0) => null;

  ContactWidget({
    Key? key,
    required double width,
    required Function(Contact) deleteWidget,
    required Contact contact,
  }) : super(key: key) {
    _width = width;
    _deleteWidget = deleteWidget;
    _contact = contact;
  }

  @override
  State<ContactWidget> createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  // removes the current contact from the sign-id user's contact list and deletes this widget
  void deleteContact() async {
    QueryResult qr = await BasicContact.deleteContact(
      BasicContact(widget.contact.contactorId, widget.contact.contactedId),
    );

    if (qr.result) {
      widget._deleteWidget(widget.contact);
    } else {
      Utility.displayAlertMessage(
          context, "Failed to Delete Contact", "Please try again.");
    }
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
                    onPressed: deleteContact,
                    icon: const Icon(
                      Icons.person_remove_rounded,
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
