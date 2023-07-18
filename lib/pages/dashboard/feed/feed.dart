import 'package:cao_prototype/models/thread_comment.dart';
import 'package:cao_prototype/models/thread_media.dart';
import 'package:cao_prototype/models/thread_tag.dart';
import 'package:cao_prototype/models/university.dart';
import 'package:cao_prototype/pages/dashboard/feed/components/thread.dart';
import 'package:cao_prototype/pages/dashboard/feed/components/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/create_thread.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/models/thread_media_file.dart';
import 'package:cao_prototype/pages/dashboard/feed/thread_page/thread_page.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/models/thread.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class DashboardFeed extends StatefulWidget {
  const DashboardFeed({super.key});

  @override
  State<DashboardFeed> createState() => _DashboardFeedState();
}

class _DashboardFeedState extends State<DashboardFeed> {
  ScrollController feedController = ScrollController();

  List<ThreadWidget> threadWidgets = List.empty(growable: true);
  List<MultiSelectItem<University>> multiselectUniversityItems =
      List.empty(growable: true);

  List<University> filteredUniversities = List.empty(growable: true);
  DateTime filteredLowerDate = DateTime(2020, 1, 1, 0, 0, 0);
  Duration selectedThreadAge = const Duration(days: 1);

  bool isLoading = false;
  bool isThreadFilterVisible = false;

  @override
  void initState() {
    super.initState();
    getThreadsOnStart();
  }

  Future<void> getUniversities() async {
    QueryResult qr = QueryResult();
    qr = await University.getUniversities();

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "Failed to Load Data", "Please try again.");
      return;
    }

    multiselectUniversityItems.clear();

    for (University u in qr.data) {
      multiselectUniversityItems.add(MultiSelectItem(u, u.toString()));
      filteredUniversities.add(
          u); // Loading university filters automatically. This will be replaced with user's filter preferences.
    }

    setState(() {
      multiselectUniversityItems;
    });
  }

  void getThreadsOnStart() async {
    // must wait for university data to get the university ids that are part of the thread filtering options
    await getUniversities();
    getThreads();
  }

  void getThreads() async {
    setState(() {
      isLoading = true;
    });

    List<int> currentThreadIds = List.empty(growable: true);

    for (ThreadWidget tw in threadWidgets) {
      currentThreadIds.add(tw.thread.id);
    }

    List<int> filteredUniversityIds = List.empty(growable: true);

    for (University u in filteredUniversities) {
      filteredUniversityIds.add(u.id);
    }

    //threadWidgets.clear();

    QueryResult qr = await Thread.getFilteredThreads(
      filteredUniversityIds,
      currentThreadIds,
      filteredLowerDate,
    );

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

  void displayThreadFilterOptions() {
    setState(() {
      isThreadFilterVisible = true;
    });
  }

  void closeThreadFilterOptions() {
    setState(() {
      isThreadFilterVisible = false;
    });
  }

  void confirmUniversityFilter(List<University> universities) {
    filteredUniversities.clear();
    for (University university in universities) {
      filteredUniversities.add(university);
    }
  }

  void onMaximumThreadAgeSelected(Duration? duration) {
    if (duration == null) {
      return;
    }

    filteredLowerDate = DateTime.now().subtract(duration);
    setState(() {
      selectedThreadAge = duration;
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
              onPressed: getThreads,
              icon: const Icon(Icons.refresh),
            ),
          ),
          IconButton(
            onPressed: navigateToThreadCreation,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: displayThreadFilterOptions,
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: Text(
                "Loading Feed...",
                style: TextStyle(fontSize: 20, color: Utility.secondaryColor),
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  controller: feedController,
                  itemCount: threadWidgets.length,
                  itemBuilder: (context, index) {
                    return threadWidgets[index];
                  },
                ),
                Visibility(
                  visible: isThreadFilterVisible,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      color: Utility.primaryColor,
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "Thread Filters",
                                  style: TextStyle(
                                    color: Utility.secondaryColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: closeThreadFilterOptions,
                                icon: const Icon(
                                  Icons.close,
                                  color: Utility.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                              child: DropdownMenu(
                                width: MediaQuery.of(context).size.width * 0.99,
                                leadingIcon: const Icon(
                                  Icons.alarm,
                                  color: Utility.secondaryColor,
                                ),
                                enableSearch: false,
                                enableFilter: false,
                                textStyle: const TextStyle(
                                  color: Utility.secondaryColor,
                                ),
                                onSelected: onMaximumThreadAgeSelected,
                                initialSelection: selectedThreadAge,
                                dropdownMenuEntries: const [
                                  DropdownMenuEntry<Duration>(
                                    value: Duration(days: 1),
                                    label: "1 Day",
                                  ),
                                  DropdownMenuEntry<Duration>(
                                    value: Duration(days: 3),
                                    label: "3 Days",
                                  ),
                                  DropdownMenuEntry<Duration>(
                                    value: Duration(days: 7),
                                    label: "1 Week",
                                  ),
                                  DropdownMenuEntry<Duration>(
                                    value: Duration(days: 14),
                                    label: "2 Weeks",
                                  ),
                                  DropdownMenuEntry<Duration>(
                                    value: Duration(days: 30),
                                    label: "1 Month",
                                  ),
                                  DropdownMenuEntry<Duration>(
                                    value: Duration(days: 90),
                                    label: "3 Months",
                                  ),
                                  DropdownMenuEntry<Duration>(
                                    value: Duration(days: 36500),
                                    label: "All Time",
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: MultiSelectDialogField(
                                listType: MultiSelectListType.CHIP,
                                initialValue: filteredUniversities,
                                items: multiselectUniversityItems,
                                onConfirm: confirmUniversityFilter,
                                searchable: true,
                                buttonText: const Text(
                                  "Universities",
                                  style:
                                      TextStyle(color: Utility.secondaryColor),
                                ),
                                confirmText: const Text(
                                  "Confirm",
                                  style: TextStyle(color: Utility.primaryColor),
                                ),
                                cancelText: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Utility.primaryColor),
                                ),
                                searchIcon: const Icon(Icons.search),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
