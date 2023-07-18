import 'package:cao_prototype/models/thread.dart';
import 'package:cao_prototype/models/thread_comment.dart';
import 'package:cao_prototype/models/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/components/thread.dart';
import 'package:cao_prototype/pages/dashboard/feed/components/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/components/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/thread_page/components/thread_comment.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class ThreadPage extends StatefulWidget {
  Thread _thread = Thread.empty();
  double _width = -1;
  bool _enableMapButton =
      true; // if true and the associated thread has a gps coordinate, then the map button will be visible
  Thread get thread => _thread;
  double get width => _width;
  bool get enableMapButton => _enableMapButton;

  ThreadPage(
      {Key? key,
      required Thread thread,
      required double width,
      bool enableMapButton = true})
      : super(key: key) {
    _thread = thread;
    _width = width;
    _enableMapButton = enableMapButton;
  }

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  //List<Widget> listViewWidgets = List.empty(growable: true);
  //List<ThreadCommentWidget> threadCommentWidgets = List.empty(growable: true);
  List<ThreadComment> threadComments = List.empty(growable: true);

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getThreadComments();
  }

  void getThreadComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      QueryResult qr = await ThreadComment.getThreadComments(widget.thread.id);
      print(qr);

      if (qr.result == false) {
        throw Exception();
      }

      threadComments = qr.data;
    } catch (e) {
      Utility.displayAlertMessage(context, "Failed to Fetch Thread Data", "");
    }

    setState(() {
      isLoading = false;
    });
  }

  /* Called from one of the thread comment widgets in the thread page. Updates the threadComment list here in the thread page with the new state of a comment.
     Let the thread comment widget know the result of the list update */
  Future<bool> likeComment(ThreadComment tc) async {
    for (int i = 0; i < threadComments.length; ++i) {
      if (threadComments[i].id == tc.id) {
        threadComments[i] = tc;
        return true;
      }
    }

    return false; // let the thread comment widget know the result of the list update
  }

  // Called from one of the thread comment widgets in the thread page.
  Future<bool> createReplyComment(ThreadComment tc) async {
    if (tc.content.isEmpty) {
      Utility.displayAlertMessage(context, "Failed to Create Comment",
          "Empty comments are not allowed.");
      return false;
    }

    QueryResult qr = await ThreadComment.createThreadComment(tc);

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "Failed to Create Comment", qr.message);
      return false;
    }

    // give the newly created comment its unique id, courtesy of the back end http response
    tc.setId(qr.data.id);

    // add thread comment
    setState(() {
      threadComments.add(tc);
    });

    Utility.displayAlertMessage(context, "Comment Creation Successful", "");

    return qr.result;
  }

  // Called from the only thread widget component on the thread page. Send a bool result back to the thread component to indicate success or faiu
  Future<bool> createComment(ThreadComment tc) async {
    if (tc.content.isEmpty) {
      Utility.displayAlertMessage(context, "Failed to Create Comment",
          "Empty comments are not allowed.");
      return false;
    }

    QueryResult qr = await ThreadComment.createThreadComment(tc);

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "Failed to Create Comment", qr.message);
      return false;
    }

    // give the newly created comment its unique id, courtesy of the back end http response
    tc.setId(qr.data.id);

    // add thread comment
    setState(() {
      threadComments.add(tc);
    });

    Utility.displayAlertMessage(context, "Comment Creation Successful", "");

    // proceed with creating the comment
    return qr.result;
  }

  // Called from WillPopScope when a pop event occurs on this page. The current state of the thread on this page is return when the pop event occurs.
  void popThreadPage() {
    Navigator.pop<Thread>(context, widget.thread);
  }

  void dummyOpenThread(Thread thread) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.tertiaryColor,
      appBar: AppBar(
        title: const Text(
          "Thread",
          style: TextStyle(color: Utility.secondaryColor),
        ),
        backgroundColor: Utility.primaryColor,
      ),
      body: WillPopScope(
        onWillPop: () async {
          popThreadPage();
          return false;
        },
        child: ListView.builder(
            itemCount: threadComments.length + 1,
            itemBuilder: (context, index) {
              /* The first widget is not actually a ThreadCommentWidget, but is being built here anyway as it is the only time a ThreadWidget is built.
               The rest of the widgets are ThreadCommentWidgets */
              if (index == 0) {
                return ThreadWidget.threadPage(
                  thread: widget.thread,
                  createComment: createComment,
                  width: widget.width,
                  enableMapButton: widget.enableMapButton,
                );
              } else {
                // conditionally return the type of ThreadCommentWidget according to whether it has a parent comment

                ThreadCommentWidget tcw;
                ThreadComment comment = threadComments[index - 1];
                if (comment.parentId != -1) {
                  ThreadComment parentComment = ThreadComment.empty();
                  for (ThreadComment tc in threadComments) {
                    if (tc.id == comment.parentId) {
                      parentComment = tc;
                      break;
                    }
                  }

                  tcw = ThreadCommentWidget.parent(
                    parentComment: parentComment,
                    comment: threadComments[index - 1],
                    likeComment: likeComment,
                    createReplyComment: createReplyComment,
                    hideReplyInput: true,
                  );
                } else {
                  tcw = ThreadCommentWidget(
                    comment: comment,
                    likeComment: likeComment,
                    createReplyComment: createReplyComment,
                    hideReplyInput: true,
                  );
                }

                return tcw;
              }
            }),
      ),
    );
  }
}
