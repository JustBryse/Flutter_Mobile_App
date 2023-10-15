import 'dart:convert';
import 'dart:ffi';

import 'package:cao_prototype/models/individual.dart';
import 'package:cao_prototype/models/organization.dart';
import 'package:cao_prototype/models/structures/user_relationship.dart';
import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/time_utility.dart';

class UserProfile {
  // the user data belonging to this profile
  User _user = User.none();
  User get user => _user;
  // the relationship between the user of this profile and the profile observer from the observer's perspective
  UserRelationship _ur = UserRelationship.none();
  UserRelationship get ur => _ur;

  UserProfile.none();
  /* the user argument is the user that belongs to this profile and the userRelationship is the relationship between the profile user
  and the user who is observing the profile from the perspective of the observer */
  UserProfile.all(
    User user,
    UserRelationship ur,
  ) {
    _user = user;
    _ur = ur;
  }

  void setUserRelationship(UserRelationship ur) {
    _ur = ur;
  }

  // the observerId refers to the user who wants to view the user profile and the observedId is the user of the profile
  static Future<QueryResult> getUserProfile(
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
        "fetch/user_profile",
      );

      var fields = jsonDecode(response);

      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];

      if (qr.result == false) {
        return qr;
      }

      var userProfileFields = fields["user_profile"];
      var userRelationshipFields = userProfileFields["user_relationship"];
      var userFields = userProfileFields["user"];

      User user = User.none();

      if (userFields["account_type"] ==
          User.getAccountTypeCode(AccountTypes.INDIVIDUAL)) {
        user = Individual.all(
          userFields["id"],
          userFields["email"],
          userFields["password"],
          userFields["alias"],
          userFields["first_name"],
          userFields["last_name"],
        );
      } else if (userFields["account_type"] ==
          User.getAccountTypeCode(AccountTypes.ORGANIZATION)) {
        user = Organization.all(
          userFields["id"],
          userFields["email"],
          userFields["password"],
          userFields["alias"],
          userFields["name"],
        );
      }

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

      UserRelationship ur = UserRelationship.all(
        userRelationshipFields["observer_id"],
        userRelationshipFields["observed_id"],
        friendDate,
        contactDate,
        friendRequestDate,
      );

      qr.data = UserProfile.all(user, ur);
    } catch (e) {
      qr.result = false;
      print("Error in UserProfile.getUserProfile(): $e");
    }
    return qr;
  }
}
