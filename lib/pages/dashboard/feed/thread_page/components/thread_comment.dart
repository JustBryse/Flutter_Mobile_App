import 'package:cao_prototype/models/thread.dart';
import 'package:cao_prototype/models/thread_comment.dart';
import 'package:cao_prototype/pages/dashboard/feed/components/thread.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ThreadCommentWidget extends StatefulWidget {
  ThreadComment _parentComment = ThreadComment.empty();
  ThreadComment _comment = ThreadComment.empty();
  bool _hideReplyInput = true;
  ThreadComment get comment => _comment;
  ThreadComment get parentComment => _parentComment;
  bool get hideReplyInput => _hideReplyInput;
  Function(ThreadComment) _likeComment = (p0) {};
  Function(ThreadComment) _createReplyComment = (p0) {};

  ThreadCommentWidget(
      {Key? key,
      required ThreadComment comment,
      required Function(ThreadComment) likeComment,
      required Function(ThreadComment) createReplyComment,
      required bool hideReplyInput})
      : super(key: key) {
    _comment = comment;
    _likeComment = likeComment;
    _createReplyComment = createReplyComment;
    _hideReplyInput = hideReplyInput;
  }

  ThreadCommentWidget.parent(
      {Key? key,
      required ThreadComment parentComment,
      required ThreadComment comment,
      required Function(ThreadComment) likeComment,
      required Function(ThreadComment) createReplyComment,
      required bool hideReplyInput})
      : super(key: key) {
    _parentComment = parentComment;
    _comment = comment;
    _likeComment = likeComment;
    _createReplyComment = createReplyComment;
    _hideReplyInput = hideReplyInput;
  }

  @override
  State<ThreadCommentWidget> createState() => _ThreadCommentWidgetState();
}

class _ThreadCommentWidgetState extends State<ThreadCommentWidget> {
  final TextEditingController replyInputTEC = TextEditingController();
  Widget upVoteButton = Placeholder();

  void upVote() async {
    await widget._comment.incrementUpVote();
    setUpVoteButton();
    // inform the thread page of the new state of the thread comment in this widget
    bool result = await widget._likeComment(widget.comment);
  }

  void rescindUpVote() async {
    await widget._comment.rescindUpVote();
    setUpVoteButton();
    // inform the thread page of the new state of the thread comment in this widget
    bool result = await widget._likeComment(widget.comment);
  }

  void setUpVoteButton() {
    if (widget.comment.threadCommentVote.upVoteState) {
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

  // tell the thread page to start the creation of a comment that is a reply to this comment (mainly pass on the ID of this comment as the new comment's parent ID)
  void createReplyComment() async {
    bool result = await widget._createReplyComment(ThreadComment.create(
      replyInputTEC.text,
      0,
      0,
      Session.currentUser.id,
      Session.currentUser.alias,
      widget.comment.threadId,
      widget.comment.id,
    ));

    if (result) {
      hideReplyInput();
    }
  }

  void showReplyInput() {
    setState(() {
      widget._hideReplyInput = false;
    });
  }

  void hideReplyInput() {
    setState(() {
      replyInputTEC.text = "";
      widget._hideReplyInput = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    setUpVoteButton();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Utility.primaryColor),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        // user alias row
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          const Icon(
            Icons.account_box,
            color: Utility.primaryColor,
          ),
          Text(
            widget.comment.userAlias,
            overflow: TextOverflow.clip,
            style: const TextStyle(color: Utility.primaryColor),
          ),

          // only indicate that this comment is a reply if it has a parent
          if (widget.comment.parentId != -1)
            Row(children: [
              const Icon(
                Icons.arrow_right,
                color: Utility.primaryColor,
              ),
              const Icon(
                Icons.account_box,
                color: Utility.primaryColor,
              ),
              Text(
                widget.parentComment.userAlias,
                overflow: TextOverflow.clip,
                style: const TextStyle(color: Utility.primaryColor),
              ),
            ]),
        ]),

        // content text
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
          child: Text(
            widget.comment.content,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              color: Utility.primaryColor,
              fontSize: 15,
            ),
          ),
        ),

        // button row
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.comment.upVotes.toString(),
                style: const TextStyle(
                  color: Utility.primaryColor,
                  fontSize: 20,
                ),
              ),
            ),
            upVoteButton,
            IconButton(
              icon: const Icon(
                Icons.add_comment,
                color: Utility.primaryColor,
              ),
              onPressed: showReplyInput,
            ),
          ],
        ),

        // reply text input box
        if (!widget.hideReplyInput)
          Column(children: [
            TextField(
              controller: replyInputTEC,
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
                  onPressed: hideReplyInput,
                  icon: const Icon(Icons.cancel),
                ),
                IconButton(
                  onPressed: createReplyComment,
                  icon: const Icon(
                    Icons.done_sharp,
                    color: Utility.primaryColor,
                  ),
                ),
              ],
            )
          ]),
      ]),
    );
  }
}
