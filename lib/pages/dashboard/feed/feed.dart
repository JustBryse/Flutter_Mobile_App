import 'package:cao_prototype/models/thread_comment.dart';
import 'package:cao_prototype/models/thread_media.dart';
import 'package:cao_prototype/models/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/components/thread.dart';
import 'package:cao_prototype/pages/dashboard/feed/components/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/create_thread.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/models/thread_media_file.dart';
import 'package:cao_prototype/pages/dashboard/feed/thread_page/thread_page.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/models/thread.dart';

class DashboardFeed extends StatefulWidget {
  const DashboardFeed({super.key});

  @override
  State<DashboardFeed> createState() => _DashboardFeedState();
}

class _DashboardFeedState extends State<DashboardFeed> {
  ScrollController feedController = ScrollController();

  List<ThreadWidget> threadWidgets = List.empty(growable: true);

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getThreads();
  }

  void getThreads() async {
    threadWidgets.clear();
    setState(() {
      isLoading = true;
    });
    QueryResult qr = await Thread.getThreads();

    if (qr.result == false) {
      Utility.displayAlertMessage(context, "Failed to Load Threads", "");
      print("Error message: " + qr.message);
      return;
    }

    for (Thread thread in qr.data) {
      double width = MediaQuery.of(context).size.width * 0.95;
      threadWidgets.add(
        ThreadWidget.feed(
          thread: thread,
          openThread: navigateToThreadPage,
          width: width,
        ),
      );
    }

    setState(() {
      threadWidgets;
      isLoading = false;
    });
  }

  // pushes the thread creation page onto the stack
  void navigateToThreadCreation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThreadCreationPage(),
      ),
    );
  }

  // activated when the user expands a thread to view its inner contents (body text and comments)
  void navigateToThreadPage(Thread thread) {
    double width = MediaQuery.of(context).size.width * 0.95;
    Navigator.push(
      context,
      MaterialPageRoute<Thread>(
        builder: (_) => ThreadPage(
          thread: thread,
          width: width,
        ),
      ),
      /* Update the thread widget in the feed after returning from the thread page. 
      This is done in case the user changed attributes of the thread, like the vote count, from within the thread page, for example.*/
    ).then((thread) => updateThreadWidget(thread));
  }

  // updates one of the thread widgets with a new or updated thread object
  void updateThreadWidget(Thread? thread) {
    if (thread == null) {
      return;
    }

    /* Create a new thread widget list with the updated thread widget. This is because the widget list in the ListView is immutable. Updating any of its list item widgets
       requires completely replacing the threadWidgets list */

    List<ThreadWidget> newThreadWidgets = List.empty(growable: true);

    for (int i = 0; i < threadWidgets.length; ++i) {
      if (threadWidgets[i].thread.id == thread.id) {
        double width = MediaQuery.of(context).size.width * 0.95;
        newThreadWidgets.add(
          ThreadWidget.feed(
            thread: thread,
            openThread: navigateToThreadPage,
            width: width,
          ),
        );
      } else {
        newThreadWidgets.add(threadWidgets[i]);
      }
    }

    // refresh the UI

    setState(() {
      threadWidgets = newThreadWidgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.primaryColorTranslucent,
      appBar: AppBar(
        title: const Text(
          "Feed",
          style: TextStyle(
            fontSize: Utility.titleFontSize,
            color: Utility.secondaryColor,
          ),
        ),
        backgroundColor: Utility.primaryColor,
        actions: [
          AbsorbPointer(
            absorbing: isLoading,
            child: IconButton(
                onPressed: getThreads, icon: const Icon(Icons.refresh)),
          ),
          IconButton(
              onPressed: navigateToThreadCreation, icon: const Icon(Icons.add))
        ],
      ),
      body: isLoading
          ? const Center(
              child: Text(
                "Loading Feed...",
                style: TextStyle(fontSize: 20, color: Utility.secondaryColor),
              ),
            )
          : ListView.builder(
              controller: feedController,
              itemCount: threadWidgets.length,
              itemBuilder: (context, index) {
                return threadWidgets[index];
              },
            ),
    );
  }
}
