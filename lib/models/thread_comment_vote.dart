import 'dart:convert';

import 'package:cao_prototype/models/thread.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/session.dart';

class ThreadCommentVote {
  int _id = -1;
  int _commentId = -1;
  int _userId = -1;
  bool _upVoteState = false;
  bool _downVoteState = false;

  int get id => _id;
  int get commentId => _commentId;
  int get userId => _userId;
  bool get upVoteState => _upVoteState;
  bool get downVoteState => _downVoteState;

  @override
  String toString() {
    return {
      "id": id,
      "commentId": commentId,
      "userId": userId,
      "upVoteState": upVoteState,
      "downVoteState": downVoteState
    }.toString();
  }

  ThreadCommentVote.none();

  ThreadCommentVote.fetch(this._id, this._commentId, this._userId,
      this._upVoteState, this._downVoteState);

  static Future<QueryResult> incrementUpVote(
      int commentId, bool isRecastVote) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "comment_id": commentId,
        "voter_user_id": Session.currentUser.id,
        "is_recast_vote": isRecastVote
      };
      var response = await Server.submitPostRequest(
          arguments, "update/thread_comment/increment-up-vote");

      print(response);

      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.message = fields["message"];
      bool upVoteState = fields["comment_vote"]["up_vote_state"] == 1;
      bool downVoteState = fields["comment_vote"]["down_vote_state"] == 1;
      qr.data = ThreadCommentVote.fetch(
          fields["comment_vote"]["id"],
          fields["comment_vote"]["comment_id"],
          fields["comment_vote"]["user_id"],
          upVoteState,
          downVoteState);
    } catch (e) {
      qr.message = "Error in ThreadCommentVote.incrementUpVote(): $e";
    }

    return qr;
  }

  static Future<QueryResult> rescindUpVote(int commentId) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "comment_id": commentId,
        "voter_user_id": Session.currentUser.id,
      };
      var response = await Server.submitPostRequest(
          arguments, "update/thread_comment/rescind-up-vote");

      print(response);

      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.message = fields["message"];
      bool upVoteState = fields["comment_vote"]["up_vote_state"] == 1;
      bool downVoteState = fields["comment_vote"]["down_vote_state"] == 1;
      qr.data = ThreadCommentVote.fetch(
          fields["comment_vote"]["id"],
          fields["comment_vote"]["comment_id"],
          fields["comment_vote"]["user_id"],
          upVoteState,
          downVoteState);
    } catch (e) {
      qr.message = "Error in ThreadCommentVote.incrementUpVote(): $e";
    }

    return qr;
  }
}
