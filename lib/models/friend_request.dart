import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:flutter/material.dart';

// the BasicFriendRequest simply contains fields for the corrosponding columns of the SQL FRIEND_REQUEST table
class BasicFriendRequest {
  DateTime _insertDate = DateTime(0);
  DateTime _editDate = DateTime(0);

  DateTime get insertDate => _insertDate;
  DateTime get editDate => _editDate;

  int _recipientId = -1;
  int _requesterId = -1;

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
    throw Exception("Not implemented.");
  }

  static Future<QueryResult> rescindFriendRequest(
      BasicFriendRequest bfr) async {
    throw Exception("Not implemented.");
  }

  static Future<QueryResult> acceptFriendRequest(BasicFriendRequest bfr) async {
    throw Exception("Not implemented.");
  }

  static Future<QueryResult> rejectFriendRequest(BasicFriendRequest brf) async {
    throw Exception("Not implemented.");
  }
}

// FriendRequest represents a more detailed object that contains addition information about the requester and recipient
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

  // fetches all the friend requests that the current user has received
  static Future<QueryResult> getRecipientFriendRequests() async {
    throw Exception("Not implemented.");
  }

  // fetches all the friend requests that the current user has sent
  static Future<QueryResult> getRequesterFriendRequests() async {
    throw Exception("Not implemented.");
  }
}
