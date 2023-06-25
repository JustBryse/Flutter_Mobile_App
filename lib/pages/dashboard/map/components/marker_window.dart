import 'package:cao_prototype/models/thread_map_marker.dart';
import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MarkerWindow extends StatefulWidget {
  double _width = 0;
  double _height = 0;
  ThreadMapMarker _threadMapMarker = ThreadMapMarker.none();

  MarkerWindow({
    Key? key,
    required ThreadMapMarker threadMapMarker,
    required double width,
    required double height,
  }) : super(key: key) {
    _threadMapMarker = threadMapMarker;
    _width = width;
    _height = height;
  }

  @override
  State<MarkerWindow> createState() => _MarkerWindowState();
}

class _MarkerWindowState extends State<MarkerWindow> {
  // callback function to map page to disable this window
  void closeMarkerWindow() {}

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: widget._width,
        height: widget._height,
        decoration: const BoxDecoration(
          color: Utility.primaryColorTranslucent,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                      child: Icon(
                        Icons.account_box,
                        color: Utility.tertiaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                      child: Text(
                        widget._threadMapMarker.creator.alias,
                        style: const TextStyle(
                          color: Utility.tertiaryColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
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
                      onPressed: closeMarkerWindow,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                child: Text(
                  widget._threadMapMarker.markerId,
                  style: const TextStyle(
                    color: Utility.tertiaryColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Text(
                  widget._threadMapMarker.description,
                  style: const TextStyle(
                    color: Utility.tertiaryColor,
                    overflow: TextOverflow.ellipsis,
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
