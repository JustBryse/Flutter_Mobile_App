import 'dart:typed_data';
import 'package:cao_prototype/models/thread_map_marker.dart';
import 'package:cao_prototype/models/thread_media.dart';
import 'package:cao_prototype/models/thread_tag.dart';
import 'package:cao_prototype/models/thread_vote.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/models/thread_media_file.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/time_utility.dart';

class Thread {
  int _id = -1;
  String _title = "";
  String _content = "";
  int _upVotes = 0;
  int _downVotes = 0;
  int _universityId = -1;
  int _userId = -1;
  String _userAlias = "";
  ThreadVote _threadVote = ThreadVote.none();
  List<ThreadTag> _tags = List.empty(growable: true);
  List<ThreadMedia> _threadMediaList = List.empty(growable: true);
  ThreadMapMarker _threadMapMarker = ThreadMapMarker.none();

  // read-only getters
  int get id => _id;
  String get title => _title;
  String get content => _content;
  int get upVotes => _upVotes;
  int get downVotes => _downVotes;
  int get universityId => _universityId;
  int get userId => _userId;
  String get userAlias => _userAlias;
  ThreadVote get threadVote => _threadVote;
  bool get sessionUserHasVoted =>
      threadVote.id !=
      -1; // used to record whether the current user has cast a vote on this thread
  List<ThreadTag> get tags => _tags;
  List<ThreadMedia> get threadMediaList => _threadMediaList;
  ThreadMapMarker get threadMapMarker => _threadMapMarker;
  bool get hasThreadMapMarker => threadMapMarker.id != -1;

  @override
  String toString() {
    List<String> tagNames = List.empty(growable: true);
    for (ThreadTag tag in tags) {
      tagNames.add(tag.name);
    }

    List<String> mediaNames = List.empty(growable: true);
    for (ThreadMedia threadMedia in threadMediaList) {
      mediaNames.add(threadMedia.name);
    }

    return {
      "id": id,
      "title": title,
      "content": content,
      "upVotes": upVotes,
      "downVotes": downVotes,
      "universityId": universityId,
      "userId": userId,
      "userAlias": userAlias,
      "threadVote": threadVote.toString(),
      "media": mediaNames.toString(),
      "tags": tagNames.toString(),
      "threadMapMarker": threadMapMarker.toString()
    }.toString();
  }

  Thread.all(
      int id,
      String title,
      String content,
      int upVotes,
      int downVotes,
      int universityId,
      int userId,
      String userAlias,
      ThreadVote threadVote,
      List<ThreadTag> tags,
      List<ThreadMedia> threadMediaList,
      ThreadMapMarker threadMapMarker) {
    _id = id;
    _title = title;
    _content = content;
    _upVotes = upVotes;
    _downVotes = downVotes;
    _universityId = universityId;
    _userId = userId;
    _userAlias = userAlias;
    _threadVote = threadVote;
    _tags = tags;
    _threadMediaList = threadMediaList;
    _threadMapMarker = threadMapMarker;
  }

  // used when creating a new thread
  Thread.create(
      String title,
      String content,
      int universityId,
      int userId,
      List<ThreadTag> tags,
      List<ThreadMedia> threadMediaList,
      ThreadMapMarker threadMapMarker) {
    _title = title;
    _content = content;
    _universityId = universityId;
    _userId = userId;
    _tags = tags;
    _threadMediaList = threadMediaList;
    _threadMapMarker = threadMapMarker;
  }

  Thread.empty();

  Future<QueryResult> incrementUpVote() async {
    QueryResult qr = QueryResult();
    try {
      qr = await ThreadVote.incrementUpVote(id, sessionUserHasVoted);
      // update local instance threadVote after receiving updated record from back-end
      if (qr.result) {
        _threadVote = qr.data;
        _upVotes += 1;
      }
    } catch (e) {
      qr.message = "Error in incrementUpVote(): " + e.toString();
    }
    return qr;
  }

  Future<QueryResult> rescindUpVote() async {
    QueryResult qr = QueryResult();
    try {
      qr = await ThreadVote.rescindUpVote(id);
      // update local instance threadVote after receiving updated record from back-end
      if (qr.result) {
        _threadVote = qr.data;
        _upVotes -= 1;
      }
    } catch (e) {
      qr.message = "Error in rescindUpVote(): " + e.toString();
    }
    return qr;
  }

  // creates a thread in the database and Amazon S3 storage
  static Future<QueryResult> createThread(
    Thread thread,
    bool hasThreadMapMarker,
  ) async {
    QueryResult qr = QueryResult();

    List<String> tagNames = List.empty(growable: true);

    for (ThreadTag tag in thread.tags) {
      tagNames.add(tag.name);
    }

    Map<String, String> arguments = {
      "title": thread.title,
      "body": thread.content,
      "tags": jsonEncode(tagNames),
      "university_id": thread.universityId.toString(),
      "user_id": thread.userId.toString(),
      "thread_marker": jsonEncode(thread.threadMapMarker.toMap()),
      "has_thread_marker": hasThreadMapMarker.toString()
    };

    try {
      var response = await Server.submitThreadPostRequest(
          arguments, thread.threadMediaList, "create/thread");
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.message = fields["message"];
    } catch (e) {
      qr.message =
          "Thread.createThread(): Failed to insert thread. Error message: $e";
    }
    return qr;
  }

  // Requests a list of threads to be served by the back-end server. The server decides which threads to respond with.
  static Future<QueryResult> getThreads() async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "user_id": Session.currentUser.id.toString()
      };
      var response = await Server.submitGetRequest(arguments, "fetch/threads");
      Map<String, dynamic> fields = jsonDecode(response);

      //print(fields);

      qr.result = fields["result"];

      if (qr.result == false) {
        throw Exception();
      }

      List<Thread> threads = List.empty(growable: true);

      // load data into thread models

      for (var threadField in fields["threads"]) {
        // collect thread tags

        List<ThreadTag> tags = List.empty(growable: true);

        for (var tagField in threadField["tags"]) {
          ThreadTag tag = ThreadTag.all(
              tagField["id"], tagField["name"], tagField["thread_id"]);
          tags.add(tag);
        }

        // collect thread media

        List<ThreadMedia> threadMediaList = List.empty(growable: true);

        for (var mediaField in threadField["media"]) {
          ThreadMedia threadMedia = ThreadMedia.fetchWithUrl(
              mediaField["id"],
              mediaField["name"],
              mediaField["s3_object_url"],
              mediaField["thread_id"]);
          threadMediaList.add(threadMedia);
        }

        // get the thread vote record

        ThreadVote threadVote = ThreadVote.none();

        // check if the current thread has a thread vote record for the current session user
        if (threadField["requester_vote_record"]["id"] != null) {
          bool upVoteState =
              threadField["requester_vote_record"]["up_vote_state"] == 1;
          bool downVoteState =
              threadField["requester_vote_record"]["down_vote_state"] == 1;

          threadVote = ThreadVote.fetch(
              threadField["requester_vote_record"]["id"],
              threadField["requester_vote_record"]["thread_id"],
              threadField["requester_vote_record"]["user_id"],
              upVoteState,
              downVoteState);
        }

        // get the thread map marker if it exists

        ThreadMapMarker threadMapMarker = ThreadMapMarker.none();

        if (threadField["thread_marker"]["id"] != null) {
          var markerData = threadField["thread_marker"];

          threadMapMarker = ThreadMapMarker.fetch(
              markerData["id"],
              markerData["marker_id"],
              markerData["icon"],
              double.parse(markerData["latitude"].toString()),
              double.parse(markerData["longitude"].toString()),
              markerData["description"],
              markerData["thread_id"]);
        }

        // finally create the thread object and add it to the thread list

        Thread thread = Thread.all(
            threadField["id"],
            threadField["title"],
            threadField["content"],
            threadField["up_votes"],
            threadField["down_votes"],
            threadField["university_id"],
            threadField["user_id"],
            threadField["user_alias"],
            threadVote,
            tags,
            threadMediaList,
            threadMapMarker);

        threads.add(thread);
      }

      qr.data = threads;
    } catch (e) {
      print("Error in Interest.getInterests(): $e");
    }

    return qr;
  }

  // Requests a list of threads to be served by the back-end server. The server decides which threads to respond with.
  static Future<QueryResult> getFilteredThreads(
    List<int> university_ids,
    List<int> excluded_thread_ids,
    DateTime lowerDate,
  ) async {
    QueryResult qr = QueryResult();

    try {
      String lowerDateFormatted = TimeUtility.getIsoDateTime(lowerDate);

      Map<String, String> arguments = {
        "user_id": Session.currentUser.id.toString(),
        "university_ids": jsonEncode(university_ids),
        "thread_ids": jsonEncode(excluded_thread_ids),
        "lower_date": lowerDateFormatted
      };
      print(arguments);
      var response = await Server.submitGetRequest(
        arguments,
        "fetch/filtered_threads",
      );
      print(response);
      Map<String, dynamic> fields = jsonDecode(response);

      //print(fields);

      qr.result = fields["result"];

      if (qr.result == false) {
        throw Exception();
      }

      List<Thread> threads = List.empty(growable: true);

      // load data into thread models

      for (var threadField in fields["threads"]) {
        // collect thread tags

        List<ThreadTag> tags = List.empty(growable: true);

        for (var tagField in threadField["tags"]) {
          ThreadTag tag = ThreadTag.all(
              tagField["id"], tagField["name"], tagField["thread_id"]);
          tags.add(tag);
        }

        // collect thread media

        List<ThreadMedia> threadMediaList = List.empty(growable: true);

        for (var mediaField in threadField["media"]) {
          ThreadMedia threadMedia = ThreadMedia.fetchWithUrl(
              mediaField["id"],
              mediaField["name"],
              mediaField["s3_object_url"],
              mediaField["thread_id"]);
          threadMediaList.add(threadMedia);
        }

        // get the thread vote record

        ThreadVote threadVote = ThreadVote.none();

        // check if the current thread has a thread vote record for the current session user
        if (threadField["requester_vote_record"]["id"] != null) {
          bool upVoteState =
              threadField["requester_vote_record"]["up_vote_state"] == 1;
          bool downVoteState =
              threadField["requester_vote_record"]["down_vote_state"] == 1;

          threadVote = ThreadVote.fetch(
              threadField["requester_vote_record"]["id"],
              threadField["requester_vote_record"]["thread_id"],
              threadField["requester_vote_record"]["user_id"],
              upVoteState,
              downVoteState);
        }

        // get the thread map marker if it exists

        ThreadMapMarker threadMapMarker = ThreadMapMarker.none();

        if (threadField["thread_marker"]["id"] != null) {
          var markerData = threadField["thread_marker"];

          threadMapMarker = ThreadMapMarker.fetch(
              markerData["id"],
              markerData["marker_id"],
              markerData["icon"],
              double.parse(markerData["latitude"].toString()),
              double.parse(markerData["longitude"].toString()),
              markerData["description"],
              markerData["thread_id"]);
        }

        // finally create the thread object and add it to the thread list

        Thread thread = Thread.all(
            threadField["id"],
            threadField["title"],
            threadField["content"],
            threadField["up_votes"],
            threadField["down_votes"],
            threadField["university_id"],
            threadField["user_id"],
            threadField["user_alias"],
            threadVote,
            tags,
            threadMediaList,
            threadMapMarker);

        threads.add(thread);
      }

      qr.data = threads;
    } catch (e) {
      print("Error in Interest.getInterests(): $e");
    }

    return qr;
  }

  // fetches a single thread from the back end
  static Future<QueryResult> getThread(int threadId) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "thread_id": threadId.toString(),
        "user_id": Session.currentUser.id.toString(),
      };

      var response = await Server.submitGetRequest(arguments, "fetch/thread");
      print(response);
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.message = fields["message"];
      if (qr.result == false) {
        return qr;
      }

      var threadField = fields["thread"];

      List<ThreadTag> tags = List.empty(growable: true);

      for (var tagField in threadField["tags"]) {
        ThreadTag tag = ThreadTag.all(
            tagField["id"], tagField["name"], tagField["thread_id"]);
        tags.add(tag);
      }

      // collect thread media

      List<ThreadMedia> threadMediaList = List.empty(growable: true);

      for (var mediaField in threadField["media"]) {
        ThreadMedia threadMedia = ThreadMedia.fetchWithUrl(
            mediaField["id"],
            mediaField["name"],
            mediaField["s3_object_url"],
            mediaField["thread_id"]);
        threadMediaList.add(threadMedia);
      }

      // get the thread vote record

      ThreadVote threadVote = ThreadVote.none();

      // check if the current thread has a thread vote record for the current session user
      if (threadField["requester_vote_record"]["id"] != null) {
        bool upVoteState =
            threadField["requester_vote_record"]["up_vote_state"] == 1;
        bool downVoteState =
            threadField["requester_vote_record"]["down_vote_state"] == 1;

        threadVote = ThreadVote.fetch(
            threadField["requester_vote_record"]["id"],
            threadField["requester_vote_record"]["thread_id"],
            threadField["requester_vote_record"]["user_id"],
            upVoteState,
            downVoteState);
      }

      // get the thread map marker if it exists

      ThreadMapMarker threadMapMarker = ThreadMapMarker.none();

      if (threadField["thread_marker"]["id"] != null) {
        var markerData = threadField["thread_marker"];

        threadMapMarker = ThreadMapMarker.fetch(
            markerData["id"],
            markerData["marker_id"],
            markerData["icon"],
            double.parse(markerData["latitude"].toString()),
            double.parse(markerData["longitude"].toString()),
            markerData["description"],
            markerData["thread_id"]);
      }

      // finally create the thread object

      Thread thread = Thread.all(
          threadField["id"],
          threadField["title"],
          threadField["content"],
          threadField["up_votes"],
          threadField["down_votes"],
          threadField["university_id"],
          threadField["user_id"],
          threadField["user_alias"],
          threadVote,
          tags,
          threadMediaList,
          threadMapMarker);

      qr.data = thread;
    } catch (e) {
      qr.result = false;
      qr.message = "Erorr in Thread.getThread():$e";
    }
    print(qr);
    return qr;
  }
}
