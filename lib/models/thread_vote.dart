import 'dart:convert';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/session.dart';

class ThreadVote {
  int _id = -1, _threadId = -1, _userId = -1;
  bool _upVoteState = false, _downVoteState = false;

  int get id => _id;
  int get threadId => _threadId;
  int get userId => _userId;
  bool get upVoteState => _upVoteState;
  bool get downVoteState => _downVoteState;

  // this constructor is mainly used when fetching data from the server
  ThreadVote.fetch(this._id, this._threadId, this._userId, this._upVoteState,
      this._downVoteState);

  ThreadVote.none();

  @override
  String toString() {
    return {
      "id": id,
      "threadId": threadId,
      "userId": userId,
      "upVoteState": upVoteState,
      "downVoteState": downVoteState
    }.toString();
  }

  static Future<QueryResult> incrementUpVote(
      int threadId, bool isRecastVote) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "thread_id": threadId,
        "voter_user_id": Session.currentUser.id,
        "is_recast_vote": isRecastVote
      };
      var response = await Server.submitPostRequest(
          arguments, "update/thread/increment-up-vote");
      print(response);
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.message = fields["message"];
      bool upVoteState = fields["thread_vote"]["up_vote_state"] == 1;
      bool downVoteState = fields["thread_vote"]["down_vote_state"] == 1;
      ThreadVote threadVote = ThreadVote.fetch(
          fields["thread_vote"]["id"],
          fields["thread_vote"]["thread_id"],
          fields["thread_vote"]["user_id"],
          upVoteState,
          downVoteState);
      qr.data = threadVote;
    } catch (e) {
      print("Error in ThreadVote.incrementUpVote(): $e");
    }

    return qr;
  }

  static Future<QueryResult> rescindUpVote(int threadId) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "thread_id": threadId,
        "voter_user_id": Session.currentUser.id,
      };
      var response = await Server.submitPostRequest(
          arguments, "update/thread/rescind-up-vote");
      print(response);
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.message = fields["message"];

      bool upVoteState = fields["thread_vote"]["up_vote_state"] == 1;
      bool downVoteState = fields["thread_vote"]["down_vote_state"] == 1;

      ThreadVote threadVote = ThreadVote.fetch(
          fields["thread_vote"]["id"],
          fields["thread_vote"]["thread_id"],
          fields["thread_vote"]["user_id"],
          upVoteState,
          downVoteState);
      qr.data = threadVote;
    } catch (e) {
      print("Error in ThreadVote.rescindUpVote(): $e");
    }

    return qr;
  }
}
