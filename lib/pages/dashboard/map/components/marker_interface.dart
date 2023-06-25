import 'package:cao_prototype/models/thread.dart';
import 'package:cao_prototype/models/thread_map_marker.dart';
import 'package:cao_prototype/pages/dashboard/feed/thread_page/thread_page.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MarkerInterface extends StatefulWidget {
  ThreadMapMarker _threadMapMarker = ThreadMapMarker.none();

  Function(bool) _toggleMarkerInterface = (b) {};
  Function(bool) _toggleMarkerWindow = (b) {};

  MarkerInterface(
      {Key? key,
      required ThreadMapMarker threadMapMarker,
      required Function(bool) toggleMarkerInterface,
      required Function(bool) toggleMarkerWindow})
      : super(key: key) {
    _threadMapMarker = threadMapMarker;
    _toggleMarkerInterface = toggleMarkerInterface;
    _toggleMarkerWindow = toggleMarkerWindow;
  }

  @override
  State<MarkerInterface> createState() => _MarkerInterfaceState();
}

class _MarkerInterfaceState extends State<MarkerInterface> {
  // push the thread page that is associated to the current marker
  void openThreadPage() async {
    QueryResult qr = await Thread.getThread(widget._threadMapMarker.threadId);

    double width = MediaQuery.of(context).size.width * 0.95;
    Navigator.push(
      context,
      MaterialPageRoute<Thread>(
        builder: (_) => ThreadPage(
          thread: qr.data,
          width: width,
          enableMapButton:
              false, // disable the map button because the feed is being pushed from the map page
        ),
      ),
    );
  }

  // sends a message back to the map page to display the marker details
  void displayMarkerWindow() {
    widget._toggleMarkerWindow(true);
  }

  // hides marker interface by telling the map page to make the interface invisible
  void hideMarkerInterface() {
    widget._toggleMarkerInterface(false);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0),
                color: Utility.primaryColorTranslucent,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notes,
                  color: Utility.tertiaryColor,
                ),
                onPressed: displayMarkerWindow,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 4),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0),
                color: Utility.primaryColorTranslucent,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.open_in_new,
                  color: Utility.tertiaryColor,
                ),
                onPressed: openThreadPage,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0),
                color: Utility.primaryColorTranslucent,
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Utility.tertiaryColor,
                ),
                onPressed: hideMarkerInterface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
