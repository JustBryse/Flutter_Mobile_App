import 'dart:convert';

import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/time_utility.dart';
import 'package:path/path.dart';

// BasicContact represents the contents of a single record in the USER_CONTACT table of the SQL database
class BasicContact {
  int _contactorId = -1;
  int _contactedId = -1;
  int _contactLevel = -1;
  DateTime _insertDate = DateTime.now();
  DateTime _editDate = DateTime.now();

  int get contactorId => _contactorId;
  int get contactedId => _contactedId;
  int get contactLevel => _contactLevel;
  DateTime get insertDate => _insertDate;
  DateTime get editDate => _editDate;

  BasicContact(int contactorId, int contactedId) {
    _contactorId = contactorId;
    _contactedId = contactedId;
  }

  // unilaterally create a contact (follow a user)
  static Future<QueryResult> createContact(BasicContact bc) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "user_id": bc.contactorId.toString(),
        "contact_id": bc.contactedId.toString()
      };

      var response = await Server.submitPostRequest(
        arguments,
        "create/user_contact",
      );
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];
    } catch (e) {
      qr.result = false;
      qr.message = "Error in BasicContact.createContact(): $e";
    }

    return qr;
  }

  // unilaterally delete a contact (unfollow a user)
  static Future<QueryResult> deleteContact(BasicContact bc) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "user_id": bc.contactorId.toString(),
        "contact_id": bc.contactedId.toString()
      };

      var response = await Server.submitPostRequest(
        arguments,
        "delete/user_contact",
      );
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];
    } catch (e) {
      qr.result = false;
      qr.message = "Error in BasicContact.deleteContact(): $e";
    }

    return qr;
  }
}

class Contact extends BasicContact {
  // the contactor is the person who creates a contact
  User _contactor = User.none();
  // the contacted is the person who is in a contactor's contacts
  User _contacted = User.none();

  User get contactor => _contactor;
  User get contacted => _contacted;

  Contact.fetch(User contactor, User contacted, int contactLevel,
      DateTime insertDate, DateTime editDate)
      : super(contactor.id, contacted.id) {
    _contactor = contactor;
    _contacted = contacted;
    _contactLevel = contactLevel;
    _insertDate = insertDate;
    _editDate = editDate;
  }

  Map<String, dynamic> toMap() {
    return {
      "contactor": contactor.toMap(),
      "contacted": contacted.toMap(),
      "insert_date": insertDate.toIso8601String(),
      "edit_date": editDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  // get the contacts of the user defined by the "userId" argument
  static Future<QueryResult> getContacts(int userId) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {"user_id": userId.toString()};
      var response = await Server.submitGetRequest(
        arguments,
        "fetch/user_contacts",
      );
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];

      // if there was a backend issue, then return false immediately
      if (qr.result == false) {
        return qr;
      }

      // this list of users will be returned in the query result object
      List<Contact> contacts = List.empty(growable: true);

      for (var contactFields in fields["user_contacts"]) {
        // datetime objects are received in string format
        DateTime contactedUserInsertDate = DateTime(0);
        DateTime contactedUserEditDate = DateTime(0);

        var contactedUserFields = contactFields["contact"];

        if (contactedUserFields["insert_date"] != null) {
          contactedUserInsertDate = TimeUtility.getDateTimeFromFormattedPattern(
            contactedUserFields["insert_date"],
          );
        }

        if (contactedUserFields["edit_date"] != null) {
          contactedUserEditDate = TimeUtility.getDateTimeFromFormattedPattern(
            contactedUserFields["edit_date"],
          );
        }

        User contactedUser = User.all(
          contactedUserFields["id"],
          "",
          "",
          contactedUserFields["alias"],
          contactedUserInsertDate,
          contactedUserEditDate,
        );

        int contactLevel = contactFields["contact_level"];

        DateTime contactInsertDate = DateTime(0);
        DateTime contactEditDate = DateTime(0);

        if (contactFields["insert_date"] != null) {
          contactInsertDate = TimeUtility.getDateTimeFromFormattedPattern(
            contactFields["insert_date"],
          );
        }
        if (contactFields["edit_date"] != null) {
          contactEditDate = TimeUtility.getDateTimeFromFormattedPattern(
            contactFields["edit_date"],
          );
        }

        Contact contact = Contact.fetch(
          Session.currentUser,
          contactedUser,
          contactLevel,
          contactInsertDate,
          contactEditDate,
        );

        contacts.add(contact);
      }

      qr.data = contacts;
    } catch (e) {
      qr.result = false;
      qr.message = "Error in Contact.getContacts():$e";
    }
    return qr;
  }
}
