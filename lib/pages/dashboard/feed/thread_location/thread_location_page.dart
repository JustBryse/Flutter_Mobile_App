import 'dart:async';

import 'package:cao_prototype/models/thread_map_marker.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ThreadLocationPage extends StatefulWidget {
  ThreadMapMarker _threadMapMarker = ThreadMapMarker.none();
  ThreadMapMarker get threadMapMarker => _threadMapMarker;

  ThreadLocationPage({Key? key, required ThreadMapMarker threadMapMarker})
      : super(key: key) {
    _threadMapMarker = threadMapMarker;
  }

  @override
  State<ThreadLocationPage> createState() => _ThreadLocationPageState();
}

class _ThreadLocationPageState extends State<ThreadLocationPage> {
  Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  String mapStyle = "";

  @override
  void initState() {
    super.initState();
    getGoogleMapStyle();
  }

  // sets the color scheme of the map
  void getGoogleMapStyle() {
    rootBundle.loadString("assets/google_maps/styles/night.json").then((value) {
      mapStyle = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utility.primaryColor,
        title: const Text(
          "Thread Location",
          style: TextStyle(color: Utility.secondaryColor),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                widget.threadMapMarker.latitude,
                widget.threadMapMarker.longitude,
              ),
              zoom: 17,
            ),
            onMapCreated: (GoogleMapController controller) {
              mapController.complete(controller);
              controller.setMapStyle(mapStyle);
            },
            markers: {
              Marker(
                markerId: MarkerId(widget.threadMapMarker.markerId),
                position: LatLng(
                  widget.threadMapMarker.latitude,
                  widget.threadMapMarker.longitude,
                ),
                infoWindow: InfoWindow(
                  title: widget.threadMapMarker.markerId,
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}
