import 'package:cao_prototype/models/thread_map_marker.dart';
import 'package:cao_prototype/models/thread_media.dart';
import 'package:cao_prototype/models/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/create_map_marker.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/models/thread_media_file.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/components/thread_tag.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/components/thread_media.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/models/university.dart';
import 'package:cao_prototype/models/thread.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ThreadCreationPage extends StatefulWidget {
  List<ThreadTagWidget> tagWidgets = List.empty(growable: true);
  List<ThreadMediaWidget> mediaWidgets = List.empty(growable: true);
  ThreadCreationPage({super.key});

  @override
  State<ThreadCreationPage> createState() => _ThreadCreationPageState();
}

class _ThreadCreationPageState extends State<ThreadCreationPage> {
  // text input ui variables
  TextEditingController tagTEC = TextEditingController();
  TextEditingController bodyTEC = TextEditingController();
  TextEditingController titleTEC = TextEditingController();
  // variables that are dynamically chosen by user
  University selectedUniversity = University.none();
  List<ThreadMediaFile> attachedFiles = List.empty(growable: true);
  // variables that are loaded on start
  List<DropdownMenuItem<University>> universityDropDownItems =
      List.empty(growable: true);
  // used to indicate whether the user has chosen a gps coordinate for this thread
  bool isThreadMapMarkerChosen = false;
  // this is used to contain the map marker info for the marker that the user can place
  ThreadMapMarker threadMapMarker = ThreadMapMarker.none();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUniversities();
  }

  void getUniversities() async {
    // begin
    setState(() {
      universityDropDownItems.clear();
      isLoading = true;
    });

    try {
      var qr = await University.getUniversities();

      if (qr.result == false) {
        throw Exception("Bad query result when fetching universities.");
      }

      // update the ui with the university list
      for (University university in qr.data) {
        universityDropDownItems.add(
          DropdownMenuItem(
            value: university,
            child: Text(
              university.toString(),
              style: const TextStyle(fontSize: 20, color: Utility.primaryColor),
            ),
          ),
        );
      }
    } catch (e) {
      // if the database query failed then add a dummy item
      universityDropDownItems.add(DropdownMenuItem(
        value: University.none(),
        child: const Text(
          "None",
          style: TextStyle(
              fontSize: Utility.bodyFontSize, color: Utility.primaryColor),
        ),
      ));
      Utility.displayAlertMessage(context, "Failed to Fetch Data",
          "Failed to fetch university information. Please exit the page and try again.");
    }

    // end
    setState(() {
      universityDropDownItems;
      chooseUniversity(universityDropDownItems[0].value);
      isLoading = false;
    });
  }

  void chooseUniversity(university) async {
    setState(() {
      selectedUniversity = university;
    });
  }

  // insert a new thread into the database
  void createThread() async {
    if (bodyTEC.text.isEmpty || titleTEC.text.isEmpty) {
      Utility.displayAlertMessage(context, "Failed to create thread.",
          "Please check that the title and body are not empty.");
      return;
    }

    // begin
    setState(() {
      isLoading = true;
    });

    // collect http request arguments

    // collects tags

    List<ThreadTag> tags = List.empty(growable: true);
    for (ThreadTagWidget tag in widget.tagWidgets) {
      tags.add(ThreadTag.name(tag.name));
    }

    // collect media files

    List<ThreadMedia> threadMedia = List.empty(growable: true);
    for (ThreadMediaFile attachedFile in attachedFiles) {
      ThreadMedia media = ThreadMedia.create(attachedFile);
      threadMedia.add(media);
    }

    // create thread map marker object

    ThreadMapMarker newThreadMapMarker = ThreadMapMarker.none();

    if (isThreadMapMarkerChosen) {
      newThreadMapMarker = ThreadMapMarker.create(
        titleTEC.text,
        "default",
        threadMapMarker.latitude,
        threadMapMarker.longitude,
        "description",
      );
    }

    // create the thread object

    Thread thread = Thread.create(
        titleTEC.text,
        bodyTEC.text,
        selectedUniversity.getId(),
        Session.currentUser.id,
        tags,
        threadMedia,
        newThreadMapMarker);

    // send request
    QueryResult qr = await Thread.createThread(thread, isThreadMapMarkerChosen);

    if (qr.result == false) {
      Utility.displayAlertMessage(
          context, "Thread Creation Failed", qr.message);
    } else {
      Utility.displayAlertMessage(context, "Thread Creation Complete", "");
    }

    // done
    setState(() {
      isLoading = false;
    });
  }

  // allows the user to attach media files to this thread: allows only images for now
  void attachMediaFiles() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (result == null) {
      return;
    }

    for (int i = 0; i < result.files.length; i++) {
      String? path = result.paths[i];
      String? name = result.names[i];
      String? extension = result.files[i].extension;
      if (path == null || name == null || extension == null) {
        continue;
      }

      ThreadMediaFile file = ThreadMediaFile.all(name, extension, path);

      // don't allow the user to attach duplicates media files

      bool isFileAttached = false;

      for (ThreadMediaFile attachedFile in attachedFiles) {
        if (file.path == attachedFile.path) {
          isFileAttached = true;
          break;
        }
      }

      // if the chosen file is already attached then do nothing more

      if (isFileAttached == true) {
        continue;
      }

      // proceed with attaching the file

      attachedFiles.add(file);

      // create a media widget in the UI
      widget.mediaWidgets.add(
        ThreadMediaWidget(file: file, removeThreadMedia: removeThreadMedia),
      );

      setState(() {
        widget.mediaWidgets;
      });
    }
  }

  void createThreadTag() {
    if (tagTEC.text.isEmpty) {
      return;
    }

    widget.tagWidgets.add(ThreadTagWidget(
      name: tagTEC.text,
      removeThreadTag: removeThreadTag,
    ));
    setState(() {
      widget.tagWidgets;
    });
  }

  void removeThreadTag(ThreadTagWidget tag) {
    widget.tagWidgets.remove(tag);
    setState(() {
      widget.tagWidgets;
    });
  }

  void removeThreadMedia(ThreadMediaWidget media) {
    widget.mediaWidgets.remove(media);
    attachedFiles.remove(media.file);
    setState(() {
      widget.mediaWidgets;
    });
  }

  // Navigates to the map marker creation page. Expects a response with details of whether a map marker was created and map marker information.
  void navigateToMapMarkerCreationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapMarkerCreationPage(university: selectedUniversity),
      ),
    ).then(
      (result) => {
        handleMapMarkerCreationResult(result),
      },
    );
  }

  // handles the response from the thread map marker creation page, specifically the marker coordinates
  void handleMapMarkerCreationResult(Map<String, dynamic> response) {
    setState(() {
      isThreadMapMarkerChosen = response["result"];
    });

    // if the user placed a marker then save the coordinates, otherwise clear the threadMapMarker object
    if (isThreadMapMarkerChosen == true) {
      threadMapMarker = ThreadMapMarker.coordinates(
        response["latitude"],
        response["longitude"],
      );
    } else {
      threadMapMarker = ThreadMapMarker.none();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.tertiaryColor,
      appBar: AppBar(
        title: const Text(
          "New Thread",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
        backgroundColor: Utility.primaryColor,
        actions: [
          /*
          IconButton(
            onPressed: attachMediaFiles,
            icon: const Icon(Icons.attach_file),
          ),
          */
        ],
      ),
      body: isLoading
          ? Container(
              color: Utility.tertiaryColor,
              child: const Center(
                child: Text(
                  "Loading. Please wait.",
                  style: TextStyle(fontSize: 20, color: Utility.secondaryColor),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: DropdownButton(
                            style: const TextStyle(
                                color: Utility.primaryColor,
                                overflow: TextOverflow.ellipsis),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Utility.primaryColor,
                            ),
                            iconSize: 1,
                            onChanged: chooseUniversity,
                            dropdownColor: Utility.tertiaryColor,
                            underline: Container(
                              height: 0,
                            ),
                            value: selectedUniversity,
                            items: universityDropDownItems,
                          ),
                        ),
                        if (isThreadMapMarkerChosen)
                          Container(
                            color: Utility.tertiaryColor,
                            height: 50,
                            width: 50,
                            child: const Icon(
                              Icons.place,
                              color: Utility.primaryColor,
                            ),
                          ),
                        Container(
                          color: Utility.primaryColor,
                          height: 50,
                          width: 50,
                          child: IconButton(
                            onPressed: navigateToMapMarkerCreationPage,
                            icon: const Icon(
                              Icons.add_location,
                              color: Utility.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /*
                  if (attachedFiles.isNotEmpty)
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      height: 75,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Row(
                            children: widget.mediaWidgets,
                          ),
                        ],
                      ),
                    ),
                  */

                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              maxLines: 1,
                              cursorColor: Utility.primaryColor,
                              decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Utility.primaryColor),
                                ),
                                labelText: "Tag",
                                labelStyle: TextStyle(
                                  color: Utility.primaryColor,
                                ),
                              ),
                              controller: tagTEC,
                              style:
                                  const TextStyle(color: Utility.primaryColor),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            color: Utility.primaryColor,
                            child: IconButton(
                              onPressed: createThreadTag,
                              icon: const Icon(
                                Icons.add_circle,
                                color: Utility.secondaryColor,
                              ),
                            ),
                          ),
                        ]),
                  ),
                  if (widget.tagWidgets.isNotEmpty)
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      height: 75,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Row(
                            children: widget.tagWidgets,
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      maxLines: 1,
                      cursorColor: Utility.primaryColor,
                      controller: titleTEC,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Utility.primaryColor),
                        ),
                        labelText: "Title",
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          color: Utility.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Utility.primaryColor, //color of border
                        width: 0.5, //width of border
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: TextField(
                      cursorColor: Utility.primaryColor,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(
                          color: Utility.primaryColor,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Utility.primaryColor,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(0, 0, 0, 0),
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(0, 0, 0, 0),
                          ),
                        ),
                      ),
                      controller: bodyTEC,
                      maxLines: 10,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      height: 50,
                      width: 75,
                      decoration: BoxDecoration(
                        color: Utility.primaryColor,
                        border: Border.all(
                          color: Utility.primaryColor,
                          width: 0.5, //width of border
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: AbsorbPointer(
                        absorbing: isLoading,
                        child: TextButton(
                          onPressed: createThread,
                          child: const Text(
                            "Create",
                            style: TextStyle(color: Utility.secondaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
