import 'dart:convert';

import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/time_utility.dart';
import 'package:flutter/material.dart';

// the BasicFriendRequest simply contains fields for the corrosponding columns of the SQL FRIEND_REQUEST table
class BasicFriendRequest {
  DateTime _insertDate = DateTime(0);
  DateTime _editDate = DateTime(0);
  int _recipientId = -1;
  int _requesterId = -1;

  DateTime get insertDate => _insertDate;
  DateTime get editDate => _editDate;
  int get recipientId => _recipientId;
  int get requesterId => _requesterId;

  BasicFriendRequest(
    int requesterId,
    int recipientId,
  ) {
    _requesterId = requesterId;
    _recipientId = recipientId;
  }

  BasicFriendRequest.fetch(
    int requesterId,
    int recipientId,
    DateTime insertDate,
    DateTime editDate,
  ) {
    _requesterId = requesterId;
    _recipientId = recipientId;
    _insertDate = insertDate;
    _editDate = editDate;
  }

  // basic post requests
  static Future<QueryResult> createFriendRequest(BasicFriendRequest bfr) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "requester_id": bfr.requesterId.toString(),
        "recipient_id": bfr.recipientId.toString(),
      };
      var response = await Server.submitPostRequest(
        arguments,
        "create/friend_request",
      );

      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];
    } catch (e) {
      qr.result = false;
      qr.message = "Error in BasicFriendRequest.createFriendRequest():$e";
    }
    return qr;
  }

  static Future<QueryResult> rescindFriendRequest(
    BasicFriendRequest bfr,
  ) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "requester_id": bfr.requesterId.toString(),
        "recipient_id": bfr.recipientId.toString(),
      };
      var response = await Server.submitPostRequest(
        arguments,
        "update/friend_request/rescind",
      );

      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];
    } catch (e) {
      qr.result = false;
      qr.message = "Error in BasicFriendRequest.rescindFriendRequest():$e";
    }
    return qr;
  }

  static Future<QueryResult> acceptFriendRequest(BasicFriendRequest bfr) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "requester_id": bfr.requesterId.toString(),
        "recipient_id": bfr.recipientId.toString(),
      };
      var response = await Server.submitPostRequest(
        arguments,
        "update/friend_request/accept",
      );

      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];
    } catch (e) {
      qr.result = false;
      qr.message = "Error in BasicFriendRequest.acceptFriendRequest():$e";
    }
    return qr;
  }

  static Future<QueryResult> rejectFriendRequest(BasicFriendRequest bfr) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "requester_id": bfr.requesterId.toString(),
        "recipient_id": bfr.recipientId.toString(),
      };
      var response = await Server.submitPostRequest(
        arguments,
        "update/friend_request/reject",
      );

      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];
    } catch (e) {
      qr.result = false;
      qr.message = "Error in BasicFriendRequest.rejectFriendRequest():$e";
    }
    return qr;
  }
}

// FriendRequest represents a more detailed object that contains additional information about the requester and recipient
class FriendRequest extends BasicFriendRequest {
  User _requester = User.none();
  User _recipient = User.none();

  User get requester => _requester;
  User get recipient => _recipient;

  FriendRequest.empty() : super(-1, -1);

  FriendRequest.fetch(
    User requester,
    User recipient,
    DateTime insertDate,
    DateTime editDate,
  ) : super(requester.id, recipient.id) {
    _requester = requester;
    _recipient = recipient;
    _insertDate = insertDate;
    _editDate = editDate;
  }

  Map<String, dynamic> toMap() {
    return {
      "requester": requester.toMap(),
      "recipient": recipient.toMap(),
      "insert_date": TimeUtility.getIsoDateTime(insertDate),
      "edit_date": TimeUtility.getIsoDateTime(editDate),
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  // fetches all the friend requests that the current user has received
  static Future<QueryResult> getRecipientFriendRequests() async {
    QueryResult qr = QueryResult();

    try {
      Map<String, String> arguments = {
        "recipient_id": Session.currentUser.id.toString()
      };

      var response = await Server.submitGetRequest(
        arguments,
        "fetch/recipient_friend_requests",
      );

      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];

      // exit immediately if there is an error
      if (qr.result == false) {
        return qr;
      }

      List<FriendRequest> friendRequests = List.empty(growable: true);

      for (var friendRequestFields in fields["friend_requests"]) {
        DateTime friendRequestInsertDate = DateTime(0);
        DateTime friendRequestEditDate = DateTime(0);

        if (friendRequestFields["insert_date"] != null) {
          friendRequestInsertDate = TimeUtility.getDateTimeFromFormattedPattern(
            friendRequestFields["insert_date"],
          );
        }

        if (friendRequestFields["edit_date"] != null) {
          friendRequestEditDate = TimeUtility.getDateTimeFromFormattedPattern(
            friendRequestFields["edit_date"],
          );
        }

        var requesterFields = friendRequestFields["requester"];

        DateTime requesterInsertDate = DateTime(0);
        DateTime requesterEditDate = DateTime(0);

        if (requesterFields["insert_date"] != null) {
          requesterInsertDate = TimeUtility.getDateTimeFromFormattedPattern(
            requesterFields["insert_date"],
          );
        }

        if (requesterFields["edit_date"] != null) {
          requesterEditDate = TimeUtility.getDateTimeFromFormattedPattern(
            requesterFields["edit_date"],
          );
        }

        User requester = User.all(
          requesterFields["id"],
          "",
          "",
          requesterFields["alias"],
          requesterInsertDate,
          requesterInsertDate,
        );

        FriendRequest friendRequest = FriendRequest.fetch(
          requester,
          Session.currentUser,
          friendRequestInsertDate,
          friendRequestEditDate,
        );

        friendRequests.add(friendRequest);
      }

      qr.data = friendRequests;
    } catch (e) {
      qr.result = false;
      qr.message = "Error in FriendRequest.getRecipientFriendRequests(): $e";
    }

    return qr;
  }

  // fetches all the friend requests that the current user has sent
  static Future<QueryResult> getRequesterFriendRequests() async {
    QueryResult qr = QueryResult();

    try {
      Map<String, String> arguments = {
        "requester_id": Session.currentUser.id.toString(),
      };

      var response = await Server.submitGetRequest(
        arguments,
        "fetch/requester_friend_requests",
      );

      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];

      // exit immediately if something went wrong
      if (qr.result == false) {
        return qr;
      }

      List<FriendRequest> friendRequests = List.empty(growable: true);

      for (var friendRequestFields in fields["friend_requests"]) {
        DateTime friendRequestInsertDate = DateTime(0);
        DateTime friendRequestEditDate = DateTime(0);

        if (friendRequestFields["insert_date"] != null) {
          friendRequestInsertDate = TimeUtility.getDateTimeFromFormattedPattern(
            friendRequestFields["insert_date"],
          );
        }

        if (friendRequestFields["edit_date"] != null) {
          friendRequestEditDate = TimeUtility.getDateTimeFromFormattedPattern(
            friendRequestFields["edit_date"],
          );
        }

        var recipientFields = friendRequestFields["recipient"];

        DateTime recipientInsertDate = DateTime(0);
        DateTime recipientEditDate = DateTime(0);

        if (recipientFields["insert_date"] != null) {
          recipientInsertDate = TimeUtility.getDateTimeFromFormattedPattern(
            recipientFields["insert_date"],
          );
        }
        if (recipientFields["edit_date"] != null) {
          recipientEditDate = TimeUtility.getDateTimeFromFormattedPattern(
            recipientFields["edit_date"],
          );
        }

        User recipient = User.all(
          recipientFields["id"],
          "",
          "",
          recipientFields["alias"],
          recipientInsertDate,
          recipientEditDate,
        );

        FriendRequest friendRequest = FriendRequest.fetch(
          Session.currentUser,
          recipient,
          friendRequestInsertDate,
          friendRequestEditDate,
        );

        friendRequests.add(friendRequest);
      }

      qr.data = friendRequests;
    } catch (e) {
      qr.result = false;
      qr.message = "Error in FriendRequest.getRequesterFriendRequests(): $e";
    }

    return qr;
  }
}
