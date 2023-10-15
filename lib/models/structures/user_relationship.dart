// defines the relationship between two users, from the perspective of the observer
import 'dart:convert';

import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/time_utility.dart';

class UserRelationship {
  int _observerId = -1;
  int _observedId = -1;
  DateTime? _friendDate;
  DateTime? _contactDate;
  DateTime? _friendRequestDate;

  int get observerId => _observerId;
  int get observedId => _observedId;
  DateTime? get friendDate => _friendDate;
  DateTime? get contactDate => _contactDate;
  DateTime? get friendRequestDate => _friendRequestDate;

  bool get friendshipExists => _friendDate != null;
  bool get contactExists => _contactDate != null;
  bool get friendRequestExists => _friendRequestDate != null;

  UserRelationship.none();

  UserRelationship.all(
    int observerId,
    int observedId,
    DateTime? friendDate,
    DateTime? contactDate,
    DateTime? friendRequestDate,
  ) {
    _observerId = observerId;
    _observedId = observerId;
    _friendDate = friendDate;
    _contactDate = contactDate;
    _friendRequestDate = friendRequestDate;
  }

  static Future<QueryResult> getUserRelationship(
    int observerId,
    int observedId,
  ) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "observer_id": jsonEncode(observerId),
        "observed_id": jsonEncode(observedId)
      };

      var response = await Server.submitGetRequest(
        arguments,
        "fetch/user_relationship",
      );

      var fields = jsonDecode(response);

      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];

      if (qr.result == false) {
        return qr;
      }

      var userRelationshipFields = fields["user_relationship"];

      DateTime? friendDate;
      if (userRelationshipFields["friend_date"] != null) {
        friendDate = TimeUtility.getDateTimeFromFormattedPattern(
          userRelationshipFields["friend_date"],
        );
      }

      DateTime? contactDate;
      if (userRelationshipFields["contact_date"] != null) {
        contactDate = TimeUtility.getDateTimeFromFormattedPattern(
          userRelationshipFields["contact_date"],
        );
      }

      DateTime? friendRequestDate;
      if (userRelationshipFields["friend_request_date"] != null) {
        friendRequestDate = TimeUtility.getDateTimeFromFormattedPattern(
          userRelationshipFields["friend_request_date"],
        );
      }

      qr.data = UserRelationship.all(
        userRelationshipFields["observer_id"],
        userRelationshipFields["observed_id"],
        friendDate,
        contactDate,
        friendRequestDate,
      );
    } catch (e) {
      qr.result = false;
      print("Error in UserRelationship.getUserRelationship(): $e");
    }

    return qr;
  }
}
