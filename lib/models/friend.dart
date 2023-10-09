import 'dart:convert';
import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/time_utility.dart';

// BasicFriend represents a single record of the FRIEND table in the SQL database
class BasicFriend {
  int _frienderId = -1;
  int _friendedId = -1;
  int _friendLevel = -1;
  DateTime _insertDate = DateTime(0);
  DateTime _editDate = DateTime(0);

  int get frienderId => _frienderId;
  int get friendedId => _friendedId;
  int get contactLevel => _friendLevel;
  DateTime get insertDate => _insertDate;
  DateTime get editDate => _editDate;

  BasicFriend(int frienderId, int friendedId) {
    _frienderId = frienderId;
    _friendedId = friendedId;
  }

  static Future<QueryResult> deleteFriend(BasicFriend bf) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "user_id": bf.frienderId.toString(),
        "friend_id": bf.friendedId.toString()
      };
      var response = Server.submitPostRequest(arguments, "delete/friend");
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];
    } catch (e) {
      qr.result = false;
      qr.message = "Error in BasicFriend.deleteFriend(): $e";
    }
    return qr;
  }
}

class Friend extends BasicFriend {
  // the friender is the current user
  User _friender = User.none();
  // the friended is the person who was "friended" by the friender
  User _friended = User.none();

  User get friender => _friender;
  User get friended => _friended;

  Friend.none() : super(-1, -1);

  Friend.fetch(
    User friender,
    User friended,
    int friendLevel,
    DateTime insertDate,
    DateTime editDate,
  ) : super(friender.id, friended.id) {
    _friender = friender;
    _friended = friended;
    _friendLevel = friendLevel;
    _insertDate = insertDate;
    _editDate = editDate;
  }

  Map<String, dynamic> toMap() {
    return {
      "friender": friender.toMap(),
      "friended": friended.toMap(),
      "insert_date": TimeUtility.getIsoDateTime(insertDate),
      "edit_date": TimeUtility.getIsoDateTime(editDate),
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  bool _equals(Object other) {
    if (other is Friend == false) {
      return false;
    }
    Friend f = other as Friend;
    return friendedId == f.friendedId && frienderId == f.frienderId;
  }

  @override
  bool operator ==(Object other) => _equals(other);
  @override
  int get hashCode => (friendedId.toString() + frienderId.toString()).hashCode;

  // gets the friends of the current user
  static Future<QueryResult> getFriends() async {
    QueryResult qr = QueryResult();

    try {
      Map<String, String> arguments = {
        "user_id": Session.currentUser.id.toString()
      };

      var response = await Server.submitGetRequest(arguments, "fetch/friends");
      var fields = jsonDecode(response);

      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];

      if (qr.result == false) {
        return qr;
      }

      List<Friend> friends = List.empty(growable: true);
      for (var friendFields in fields["friends"]) {
        // datetime objects are received in string format
        DateTime friendUserInsertDate = DateTime(0);
        DateTime friendUserEditDate = DateTime(0);

        var friendUserFields = friendFields["friend"];

        if (friendUserFields["insert_date"] != null) {
          friendUserInsertDate = TimeUtility.getDateTimeFromFormattedPattern(
            friendUserFields["insert_date"],
          );
        }

        if (friendUserFields["edit_date"] != null) {
          friendUserEditDate = TimeUtility.getDateTimeFromFormattedPattern(
            friendUserFields["edit_date"],
          );
        }

        User friendUser = User.all(
          friendUserFields["id"],
          "",
          "",
          friendUserFields["alias"],
          friendUserInsertDate,
          friendUserEditDate,
        );

        int friendLevel = friendFields["friend_level"];

        DateTime friendInsertDate = DateTime(0);
        DateTime friendEditDate = DateTime(0);

        if (friendFields["insert_date"] != null) {
          friendInsertDate = TimeUtility.getDateTimeFromFormattedPattern(
            friendFields["insert_date"],
          );
        }

        if (friendFields["edit_date"] != null) {
          friendEditDate = TimeUtility.getDateTimeFromFormattedPattern(
            friendFields["edit_date"],
          );
        }

        Friend friend = Friend.fetch(
          Session.currentUser,
          friendUser,
          friendLevel,
          friendInsertDate,
          friendEditDate,
        );
        friends.add(friend);
      }

      qr.data = friends;
    } catch (e) {
      qr.result = false;
      qr.message = "Error in Friend.getFriends(): $e";
    }

    return qr;
  }
}
