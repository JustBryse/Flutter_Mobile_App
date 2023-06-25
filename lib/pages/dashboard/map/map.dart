import 'dart:async';
import 'package:cao_prototype/models/thread_map_marker.dart';
import 'package:cao_prototype/models/university.dart';
import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/pages/dashboard/map/components/marker_interface.dart';
import 'package:cao_prototype/pages/dashboard/map/components/marker_window.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cao_prototype/support/utility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashboardMap extends StatefulWidget {
  const DashboardMap({Key? key}) : super(key: key);

  @override
  State<DashboardMap> createState() => _DashboardMapState();
}

class _DashboardMapState extends State<DashboardMap> {
  Completer<GoogleMapController> gmController =
      Completer<GoogleMapController>();
  String mapStyle = "";

  // thread map marker objects which contain thread details associated to the marker
  Map<MarkerId, ThreadMapMarker> threadMapMarkers =
      <MarkerId, ThreadMapMarker>{};

  // google map markers
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  // all the universities that can be selected from
  List<University> universities = List.empty(growable: true);
  List<DropdownMenuItem<University>> universityMenuItems =
      List.empty(growable: true);

  // UI properties and state variables
  bool isLoading = false;
  bool enableMarkerInterface = false;
  bool enableMarkerWindow = false;
  double screenWidth = 0;
  double screenHeight = 0;

  // marker filter variables
  int markerCountLimit = 100;

  // currently selected university
  University selectedUniversity = University.none();
  // currently selected thread map marker
  ThreadMapMarker selectedThreadMapMarker = ThreadMapMarker.none();

  @override
  void initState() {
    getGoogleMapStyle();
    getUniversities();
    getMapMarkers();
  }

  // sets the color scheme of the map
  void getGoogleMapStyle() {
    rootBundle.loadString("assets/google_maps/styles/night.json").then((value) {
      mapStyle = value;
    });
  }

  // this is a get request to the back end
  void getUniversities() async {
    setState(() {
      isLoading = true;
      universities.clear();
    });

    QueryResult qr = await University.getUniversities();

    if (qr.result == false) {
      // add drop down items
      universityMenuItems.add(
        DropdownMenuItem(
          value: University.none(),
          child: const Text(
            "None",
            style: TextStyle(
              fontSize: Utility.bodyFontSize,
              color: Utility.primaryColor,
            ),
          ),
        ),
      );

      Utility.displayAlertMessage(
          context, "Failed to Load Data", "Please reload the page.");
    } else {
      for (University university in qr.data) {
        universities.add(university);
        universityMenuItems.add(DropdownMenuItem(
          value: university,
          child: Text(
            university.toString(),
            style: const TextStyle(color: Utility.tertiaryColor, fontSize: 20),
          ),
        ));
      }
      setState(() {
        // update dropdown
        selectedUniversity = universities[0];
        universityMenuItems;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // this is a get request to the back end
  void getMapMarkers() async {
    setState(() {
      isLoading = true;
    });

    threadMapMarkers.clear();
    markers.clear();

    // This list will be populated with markers from the backend. Markers are chosen according to user's filter conditions.
    //ThreadMapMarker.fetchWithCreator(id, markerId, icon, latitude, longitude, description, threadId, creator)

    QueryResult qr = await ThreadMapMarker.getThreadMapMarkers(
      markerCountLimit,
      true,
    );

    if (qr.result == false) {
      print(qr.message);
      Utility.displayAlertMessage(
          context, "Failed to Load Map Data", "Please try again.");
      return;
    }

    List<ThreadMapMarker> threadMarkers = qr.data;

    for (ThreadMapMarker tmm in threadMarkers) {
      MarkerId markerId = MarkerId(tmm.markerId);
      Marker marker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        markerId: markerId,
        position: LatLng(tmm.latitude, tmm.longitude),
        onTap: () {
          // enable UI component to show marker information and button options
          setState(() {
            selectedThreadMapMarker = threadMapMarkers[markerId]!;
            enableMarkerInterface = true;
          });
        },
      );

      setState(() {
        threadMapMarkers[markerId] = tmm;
        markers[markerId] = marker;
      });
    }

    setState(() {
      isLoading = false;
    });

    print("length of tmm = " + threadMapMarkers.length.toString());
  }

  void selectUniversity(University? university) {
    if (university == null) {
      return;
    }

    setState(() {
      selectedUniversity = university;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utility.tertiaryColor,
      appBar: AppBar(
        backgroundColor: Utility.primaryColor,
        title: const Text(
          "Thread Map",
          style: TextStyle(color: Utility.secondaryColor),
        ),
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: isLoading
            ? Container(
                color: Utility.tertiaryColor,
                child: const Center(
                  child: Text(
                    "Loading. Please wait.",
                    style:
                        TextStyle(fontSize: 20, color: Utility.secondaryColor),
                  ),
                ),
              )
            : Stack(
                children: [
                  // google map
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(selectedUniversity.latitude,
                          selectedUniversity.longitude),
                      zoom: 15,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      gmController.complete(controller);
                      controller.setMapStyle(mapStyle);
                    },
                    markers: markers.values.toSet(),
                  ),
                  // university dropdown button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                          padding: const EdgeInsets.all(8),
                          child: DropdownButton<University>(
                            style: const TextStyle(
                                color: Utility.primaryColor,
                                overflow: TextOverflow.ellipsis),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Utility.tertiaryColor,
                            ),
                            iconSize: 1,
                            dropdownColor: Utility.primaryColorTranslucent,
                            underline: Container(
                              height: 0,
                            ),
                            items: universityMenuItems,
                            value: selectedUniversity,
                            onChanged: selectUniversity,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // represents the buttons for viewing thread marker data, opening associated thread page, and closing the interface
                  Visibility(
                    visible: enableMarkerInterface,
                    child: MarkerInterface(
                      threadMapMarker: selectedThreadMapMarker,
                    ),
                  ),
                  // represents the information window that can be made to appear by pressing the marker data button of the marker interface
                  Visibility(
                    visible: enableMarkerWindow,
                    child: MarkerWindow(
                      threadMapMarker: selectedThreadMapMarker,
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
