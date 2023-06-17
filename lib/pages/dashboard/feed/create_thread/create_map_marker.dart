import 'dart:async';
import 'package:cao_prototype/models/university.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerCreationPage extends StatefulWidget {
  University _university = University.none();
  MapMarkerCreationPage({Key? key, required University university})
      : super(key: key) {
    _university = university;
  }

  @override
  State<MapMarkerCreationPage> createState() => _MapMarkerCreationPageState();
}

class _MapMarkerCreationPageState extends State<MapMarkerCreationPage> {
  final Completer<GoogleMapController> gmController =
      Completer<GoogleMapController>();
  String mapStyle = "";
  // placed-marker ID
  final MarkerId placedMarkerId = const MarkerId("Thread Marker");
  // stores all the markers on the google map
  Map<MarkerId, Marker> markers = Map<MarkerId, Marker>();

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

  // adds a marker to the google map when the user taps the map in marker mode
  void addMarker(LatLng tapCoordinate) {
    Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      markerId: placedMarkerId,
      position: tapCoordinate,
      /*infoWindow: InfoWindow(
          title: markerId.value, snippet: ""),*/
    );

    setState(() {
      markers[placedMarkerId] = marker;
    });
  }

  // return the marker coordinates to the create-thread page
  void confirmMarkerPlacement() {
    Marker? placedMarker = markers[placedMarkerId];

    Map<String, dynamic> response = {"result": false};

    if (placedMarker != null) {
      response = {
        "result": true,
        "latitude": placedMarker.position.latitude,
        "longitude": placedMarker.position.longitude
      };
      Navigator.pop(context, response);
    } else {
      Utility.displayAlertMessage(context, "No Thread Marker Found",
          "Please place a marker before confirming placement.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utility.primaryColor,
        title: const Text(
          "Thread Map",
          style: TextStyle(color: Utility.secondaryColor),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, {"result": false});
          return false;
        },
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(
                widget._university.latitude, widget._university.longitude),
            zoom: 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            gmController.complete(controller);
            controller.setMapStyle(mapStyle);
          },
          markers: markers.values.toSet(),
          onTap: addMarker,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Utility.tertiaryColor,
        onPressed: confirmMarkerPlacement,
        child: IconButton(
          iconSize: 40,
          icon: const Icon(
            Icons.done_sharp,
            color: Utility.secondaryColor,
          ),
          onPressed: confirmMarkerPlacement,
        ),
      ),
    );
  }
}
