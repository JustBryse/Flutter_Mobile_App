import 'dart:io';

import 'package:cao_prototype/models/thread.dart';
import 'package:cao_prototype/models/thread_comment.dart';
import 'package:cao_prototype/models/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/components/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/thread_location/thread_location_page.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';

class ThreadWidget extends StatefulWidget {
  Thread _thread = Thread.empty();
  double _width = 0;
  // controls whether to configure the UI for the feed page or for the thread page
  bool _feedMode = true;
  bool _enableMapButton = true;
  Thread get thread => _thread;
  // width refers to the horizontal length of media in the thread UI
  double get width => _width;
  bool get feedMode => _feedMode;
  bool get enableMapButton => _enableMapButton;
  // callback function to the feed view which is activated when the user wants to open the thread
  void Function(Thread) _openThread = (t) {};
  Future<bool> Function(ThreadComment) _createComment = (p0) async {
    return false;
  };

  ThreadWidget.feed({
    Key? key,
    required Thread thread,
    required void Function(Thread) openThread,
    required double width,
  }) : super(key: key) {
    _thread = thread;
    _openThread = openThread;
    _width = width;
    _feedMode = true;
  }

  ThreadWidget.threadPage({
    Key? key,
    required Thread thread,
    required Future<bool> Function(ThreadComment) createComment,
    required double width,
    bool enableMapButton = true,
  }) : super(key: key) {
    _thread = thread;
    _createComment = createComment;
    _width = width;
    _feedMode = false;
    _enableMapButton = enableMapButton;
  }

  @override
  State<ThreadWidget> createState() => _ThreadWidgetState();
}

class _ThreadWidgetState extends State<ThreadWidget> {
  List<FeedThreadTagWidget> tagWidgets = List.empty(growable: true);
  Widget upVoteButton = Placeholder();

  // used to keep track of the currently selected media that is displayed
  String mediaIndexText = "";
  int currentMediaIndex = 0;
  // stores the media file that is currently displayed in the thread
  var currentMedia;

  bool commentInputEnabled = false;
  final TextEditingController commentInputTEC = TextEditingController();

  @override
  void initState() {
    super.initState();

    setCurrentMedia();
  }

  void setCurrentMedia() {
    if (widget.thread.threadMediaList.isEmpty) {
      return;
    }

    currentMedia = widget.thread.threadMediaList[currentMediaIndex]
        .getImageFromBytes(widget.width, 200, BoxFit.cover);

    if (widget.thread.threadMediaList.length < 2) {
      mediaIndexText = "";
    } else {
      mediaIndexText =
          "${currentMediaIndex + 1}/${widget.thread.threadMediaList.length}";
    }

    setState(() {
      currentMedia;
      mediaIndexText;
    });
  }

  // cycles through the thread media and displays the currently selected thread media to the UI
  void traverseMedia(DragEndDetails details) {
    int sensitivity = 16;
    if (details.velocity.pixelsPerSecond.dx < sensitivity) {
      // left swipe

      if (currentMediaIndex < widget.thread.threadMediaList.length - 1) {
        currentMediaIndex++;
        setCurrentMedia();
      }
    } else if (details.velocity.pixelsPerSecond.dx > -sensitivity) {
      // right swipe
      if (currentMediaIndex > 0) {
        currentMediaIndex--;
        setCurrentMedia();
      }
    }
  }

  void openThread() {
    widget._openThread(widget.thread);
  }

  // dynamically generates the thread tag widgets for this thread widget from the thread tags (thats not confusing haha)
  void generateTagWidgets() {
    tagWidgets.clear();

    for (ThreadTag tag in widget.thread.tags) {
      tagWidgets.add(
        FeedThreadTagWidget(name: tag.name),
      );
    }

    setState(() {
      tagWidgets;
    });
  }

  void upVote() async {
    print("up vote");
    await widget._thread.incrementUpVote();
    setUpVoteButton();
    print("incrementUpVote(): " + widget.thread.threadVote.toString());
  }

  void rescindUpVote() async {
    print("rescind up vote");
    await widget._thread.rescindUpVote();
    setUpVoteButton();
    print("rescindUpVote(): " + widget.thread.threadVote.toString());
  }

  // sets the apperance and event behavior of the up-vote button
  void setUpVoteButton() {
    if (widget.thread.threadVote.upVoteState) {
      upVoteButton = IconButton(
        icon: const Icon(
          Icons.thumb_up,
          color: Utility.primaryColor,
        ),
        onPressed: rescindUpVote,
      );
    } else {
      upVoteButton = IconButton(
        icon: const Icon(
          Icons.thumb_up_alt_outlined,
          color: Utility.primaryColor,
        ),
        onPressed: upVote,
      );
    }
    setState(() {
      upVoteButton;
    });
  }

  void saveThread() {}
  void viewThreadLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ThreadLocationPage(threadMapMarker: widget.thread.threadMapMarker),
      ),
    );
  }

  // pass on the ThreadComment instance to the thread page and it will handle the rest
  void createComment() async {
    bool result = await widget._createComment(ThreadComment.create(
        commentInputTEC.text,
        0,
        0,
        Session.currentUser.id,
        Session.currentUser.alias,
        widget.thread.id,
        -1));

    if (result) {
      hideCommentInput();
    }
  }

  void hideCommentInput() {
    setState(() {
      commentInputEnabled = false;
    });
  }

  void showCommentInput() {
    setState(() {
      commentInputEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    generateTagWidgets();
    setUpVoteButton();
    return Container(
      decoration: BoxDecoration(
        color: Utility.tertiaryColor,
        border: Border.all(),
      ),
      padding: const EdgeInsets.all(8),
      // master column
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_box,
                color: Utility.primaryColor,
              ),
              Text(
                widget.thread.userAlias,
                style: const TextStyle(color: Utility.primaryColor),
              ),
            ],
          ),
          // upper container for tags
          if (tagWidgets.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Row(
                    children: tagWidgets,
                  ),
                ],
              ),
            ),
          // row 1 (thread title)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.thread.title,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                      color: Utility.primaryColor, fontSize: 30),
                ),
              ),
            ],
          ),
          // row 2 (content text)
          if (!widget.feedMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.thread.content,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(color: Utility.primaryColor),
                  ),
                ),
              ],
            ),
          // row 3 (thread media)
          if (widget.thread.threadMediaList.isNotEmpty)
            GestureDetector(
              onHorizontalDragEnd: traverseMedia,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // this container contains the first (and possibly only image associated to this thread)
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(border: Border.all()),
                    // assumes that the thread media base64 data is ready to go since (since the image data would be fetched from the server)
                    child: currentMedia,
                  ),
                ],
              ),
            ),
          // row 4 (thread buttons)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.thread.upVotes.toString(),
                    style: const TextStyle(
                        color: Utility.primaryColor, fontSize: 20),
                  ),
                ),
                upVoteButton,
                IconButton(
                  icon: const Icon(
                    Icons.star_border,
                    color: Utility.primaryColor,
                  ),
                  onPressed: saveThread,
                ),
                if (widget.feedMode)
                  IconButton(
                    icon: const Icon(
                      Icons.comment,
                      color: Utility.primaryColor,
                    ),
                    onPressed: openThread,
                  ),
                if (!widget.feedMode)
                  IconButton(
                    icon: const Icon(
                      Icons.add_comment,
                      color: Utility.primaryColor,
                    ),
                    onPressed: showCommentInput,
                  ),
                if (widget.thread.hasThreadMapMarker && widget.enableMapButton)
                  IconButton(
                    icon: const Icon(
                      Icons.fmd_good,
                      color: Utility.primaryColor,
                    ),
                    onPressed: viewThreadLocation,
                  ),
              ]),
              Row(
                children: [
                  // only show the media index if there is more than one media file associated to the thread
                  if (widget.thread.threadMediaList.length > 1)
                    Container(
                      padding: const EdgeInsets.all(4),
                      color: Utility.primaryColor,
                      child: Text(
                        mediaIndexText,
                        style: const TextStyle(
                            color: Utility.secondaryColor, fontSize: 20),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // comment text input
          if (commentInputEnabled)
            Column(children: [
              TextField(
                controller: commentInputTEC,
                maxLines: 3,
                style: const TextStyle(color: Utility.primaryColor),
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Utility.primaryColor),
                  ),
                  labelStyle: TextStyle(
                    color: Utility.primaryColor,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: hideCommentInput,
                    icon: const Icon(Icons.cancel),
                  ),
                  IconButton(
                    onPressed: createComment,
                    icon: const Icon(
                      Icons.done_sharp,
                      color: Utility.primaryColor,
                    ),
                  ),
                ],
              )
            ]),
        ],
      ),
    );
  }
}
