import 'package:cao_prototype/models/thread_map_marker.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MarkerInterface extends StatefulWidget {
  ThreadMapMarker _threadMapMarker = ThreadMapMarker.none();

  MarkerInterface({Key? key, required ThreadMapMarker threadMapMarker})
      : super(key: key) {
    _threadMapMarker = threadMapMarker;
  }

  @override
  State<MarkerInterface> createState() => _MarkerInterfaceState();
}

class _MarkerInterfaceState extends State<MarkerInterface> {
  // push the thread page that is associated to the current marker
  void openThreadPage() {}
  // sends a message back to the map page to display the marker details
  void displayMarkerDetails() {}
  // hides marker interface
  void hideMarkerInterface() {}

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
                onPressed: displayMarkerDetails,
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
