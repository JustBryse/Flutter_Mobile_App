import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cao_prototype/pages/home.dart';
import 'package:cao_prototype/support/coordinates.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  List<Uint8List> markerImages = List.empty(growable: true);

  final Completer<GoogleMapController> gmController =
      Completer<GoogleMapController>();

  // contains google map styling data and is loaded on intiialization of this page
  String mapStyle = "";

  final CameraPosition ottawa =
      const CameraPosition(target: Coordinates.ottawa, zoom: 0);

  // stores all the markers on the google map
  Map<MarkerId, Marker> markers = Map<MarkerId, Marker>();
  // holds the marker id that was most recently selected by the user
  MarkerId selectedMarker = const MarkerId("none");

  bool isMarkerModeEnabled = false;

  @override
  void initState() {
    super.initState();
    setStartMarkers();
    getGoogleMapStyle();
  }

  void getGoogleMapStyle() {
    rootBundle.loadString("assets/google_maps/styles/night.json").then((value) {
      mapStyle = value;
    });
  }

  // returns byte data of an image asset stored locally in the app data
  Future<Uint8List> getBytesFromImageAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // sets the starting map markers
  void setStartMarkers() async {
    // load image assets

    Uint8List markerData =
        await getBytesFromImageAsset('assets/images/university_icon.png', 100);
    MarkerId markerId = const MarkerId("University of Ottawa");
    Marker marker = Marker(
      icon: BitmapDescriptor.fromBytes(markerData),
      markerId: markerId,
      position: Coordinates.ottawa,
      infoWindow: InfoWindow(
          title: markerId.value, snippet: "This is a university marker"),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void pushHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }

  // adds a marker to the google map when the user taps the map in marker mode
  void addMarker(LatLng tapCoordinate) {
    if (isMarkerModeEnabled == false) {
      return;
    }

    MarkerId markerId = const MarkerId("User's Marker");
    Marker marker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      markerId: markerId,
      position: tapCoordinate,
      infoWindow: InfoWindow(
          title: markerId.value, snippet: "This is a user-placed marker"),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  // allows the user to toggle marker placement on the map
  void toggleMarkerMode() {
    isMarkerModeEnabled = !isMarkerModeEnabled;
  }

  // generates a list of menu button items when the user clicks on the menu icon
  List<PopupMenuEntry<dynamic>> getMenuItems(BuildContext context) {
    return [
      PopupMenuItem(
        child: TextButton(
          onPressed: pushHomePage,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(
                Icons.home,
                color: Utility.primaryColor,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Home",
                  style: TextStyle(color: Utility.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
      PopupMenuItem(
        child: TextButton(
          onPressed: toggleMarkerMode,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Icon(
                Icons.gps_fixed,
                color: Utility.primaryColor,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Marker Mode",
                  style: TextStyle(color: Utility.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: getMenuItems,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.menu),
            ),
          )
        ],
        backgroundColor: Utility.primaryColor,
        title: const Text(
          "CAO",
          style: TextStyle(
              fontSize: Utility.titleFontSize, color: Utility.secondaryColor),
        ),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: ottawa,
        onMapCreated: (GoogleMapController controller) {
          gmController.complete(controller);
          controller.setMapStyle(mapStyle);
        },
        markers: markers.values.toSet(),
        onTap: addMarker,
      ),
    );
  }

  /* Future<void> _goToTheLake() async {
    final GoogleMapController controller = await gmController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }*/
}
