import 'dart:convert';

import 'package:cao_prototype/models/thread_comment_vote.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/session.dart';

class ThreadComment {
  int _id = -1;
  String _content = "";
  int _upVotes = -1;
  int _downVotes = -1;
  int _userId = -1;
  String _userAlias = "";
  int _threadId = -1;
  int _parentId = -1;
  ThreadCommentVote _threadCommentVote = ThreadCommentVote.none();

  int get id => _id;
  String get content => _content;
  int get upVotes => _upVotes;
  int get downVotes => _downVotes;
  int get userId => _userId;
  String get userAlias => _userAlias;
  int get threadId => _threadId;
  int get parentId => _parentId;
  ThreadCommentVote get threadCommentVote => _threadCommentVote;
  bool get sessionUserHasVoted => threadCommentVote.id != -1;

  @override
  String toString() {
    return {
      "id": _id.toString(),
      "content": _content,
      "upVotes": _upVotes,
      "downVotes": _downVotes,
      "userId": userId,
      "userAlias": userAlias,
      "threadId": _threadId,
      "parentId": _parentId,
      "threadCommentVote": _threadCommentVote.toString()
    }.toString();
  }

  ThreadComment.empty();

  // typically used when fetching data from the server
  ThreadComment.all(
      int id,
      String content,
      int upVotes,
      int downVotes,
      int userId,
      String userAlias,
      int threadId,
      int parentId,
      ThreadCommentVote threadCommentVote) {
    _id = id;
    _content = content;
    _upVotes = upVotes;
    _downVotes = downVotes;
    _userId = userId;
    _userAlias = userAlias;
    _threadId = threadId;
    _parentId = parentId;
    _threadCommentVote = threadCommentVote;
  }

  // typically used when creating a comment in a post request
  ThreadComment.create(String content, int upVotes, int downVotes, int userId,
      String userAlias, int threadId, int parentId) {
    _content = content;
    _upVotes = upVotes;
    _downVotes = downVotes;
    _userId = userId;
    _userAlias = userAlias;
    _threadId = threadId;
    _parentId = parentId;
  }

  Future<QueryResult> incrementUpVote() async {
    QueryResult qr = QueryResult();
    try {
      qr = await ThreadCommentVote.incrementUpVote(id, sessionUserHasVoted);
      if (qr.result) {
        _threadCommentVote = qr.data;
        _upVotes += 1;
      }
    } catch (e) {
      qr.message = "Error in ThreadComment.incrementUpVote(): $e";
    }
    return qr;
  }

  Future<QueryResult> rescindUpVote() async {
    QueryResult qr = QueryResult();
    try {
      qr = await ThreadCommentVote.rescindUpVote(id);
      if (qr.result) {
        _threadCommentVote = qr.data;
        _upVotes -= 1;
      }
    } catch (e) {
      qr.message = "Error in ThreadComment.incrementUpVote(): $e";
    }
    return qr;
  }

  static Future<QueryResult> createThreadComment(ThreadComment comment) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "content": comment.content,
        "up_votes": comment.upVotes,
        "down_votes": comment.downVotes,
        "user_id": comment.userId,
        "user_alias": comment.userAlias,
        "thread_id": comment.threadId,
        "parent_id": comment.parentId
      };

      var response =
          await Server.submitPostRequest(arguments, "create/thread_comment");
      Map<String, dynamic> fields = jsonDecode(response);
      qr.result = fields["result"];
    } catch (e) {
      qr.message = "Failed to create thread comment. Error: $e";
    }
    return qr;
  }

  static Future<QueryResult> getThreadComments(int threadId) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "thread_id": threadId.toString(),
        "user_id": Session.currentUser.id.toString()
      };
      var response =
          await Server.submitGetRequest(arguments, "fetch/thread_comments");
      Map<String, dynamic> fields = jsonDecode(response);

      qr.result = fields["result"];

      if (qr.result == false) {
        throw Exception();
      }

      List<ThreadComment> threadComments = List.empty(growable: true);

      for (var commentField in fields["comments"]) {
        // only get the thread comment vote information if there is such a record for this comment and session user (so only if the user previously cast a vote)
        ThreadCommentVote threadCommentVote = ThreadCommentVote.none();
        if (commentField["thread_comment_vote"]["id"] != null) {
          bool upVoteState =
              commentField["thread_comment_vote"]["up_vote_state"] == 1;
          bool downVoteState =
              commentField["thread_comment_vote"]["down_vote_state"] == 1;

          threadCommentVote = ThreadCommentVote.fetch(
              commentField["thread_comment_vote"]["id"],
              commentField["thread_comment_vote"]["comment_id"],
              commentField["thread_comment_vote"]["user_id"],
              upVoteState,
              downVoteState);
        }

        ThreadComment comment = ThreadComment.all(
            commentField["id"],
            commentField["content"],
            commentField["up_votes"],
            commentField["down_votes"],
            commentField["user_id"],
            commentField["user_alias"],
            commentField["thread_id"],
            commentField["parent_id"],
            threadCommentVote);
        threadComments.add(comment);
      }

      qr.data = threadComments;
    } catch (e) {
      qr.message = "Failed to get thread comments. Error: $e";
      qr.result = false;
    }

    return qr;
  }
}
