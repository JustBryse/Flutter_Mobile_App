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
  GoogleMapController? mapController;
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
  bool isMarkerFilterInterfaceVisible = false;
  bool isLoadingMoreMarkers = false;
  double screenWidth = 0;
  double screenHeight = 0;

  // marker filter variables
  int markerCountLimit = 10;
  Duration selectedThreadAge = Duration.zero;
  DateTime filteredLowerDate = DateTime(2020, 1, 1, 0, 0, 0);
  University selectedUniversity = University.none();
  double maxMarkerDistance = 1; // distance in kilometers

  // currently selected thread map marker
  ThreadMapMarker selectedThreadMapMarker = ThreadMapMarker.none();

  @override
  void initState() {
    initialize();
  }

  // initializes the map page
  void initialize() async {
    getGoogleMapStyle();
    await getUniversities();
    getMapMarkers();
  }

  // sets the color scheme of the map
  void getGoogleMapStyle() async {
    mapStyle = await rootBundle.loadString(
      "assets/google_maps/styles/night.json",
    );
  }

  // this is a get request to the back end
  Future<void> getUniversities() async {
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
            style: const TextStyle(
              color: Utility.secondaryColor,
            ),
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

    QueryResult qr = await ThreadMapMarker.getFilteredThreadMapMarkers(
      List.empty(),
      selectedUniversity.id,
      maxMarkerDistance,
      filteredLowerDate,
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
      MarkerId markerId = MarkerId(tmm.id.toString());
      Marker marker = Marker(
        infoWindow: InfoWindow(title: tmm.markerId),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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

      threadMapMarkers[markerId] = tmm;
      markers[markerId] = marker;
    }

    setState(() {
      markers;
      threadMapMarkers;
      isLoading = false;
    });
  }

  // this is a get request to the back end
  void getMoreMapMarkers() async {
    setState(() {
      isLoadingMoreMarkers = true;
    });

    List<int> threadMapMarkerIds = List.empty(growable: true);

    for (ThreadMapMarker tmm in threadMapMarkers.values) {
      threadMapMarkerIds.add(tmm.id);
    }

    QueryResult qr = await ThreadMapMarker.getFilteredThreadMapMarkers(
      threadMapMarkerIds,
      selectedUniversity.id,
      maxMarkerDistance,
      filteredLowerDate,
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
      MarkerId markerId = MarkerId(tmm.id.toString());
      Marker marker = Marker(
        infoWindow: InfoWindow(title: tmm.markerId),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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

      threadMapMarkers[markerId] = tmm;
      markers[markerId] = marker;
    }

    setState(() {
      markers;
      threadMapMarkers;
      isLoadingMoreMarkers = false;
    });
  }

  void selectUniversity(University? university) {
    if (university == null) {
      return;
    }

    setState(() {
      selectedUniversity = university;
    });

    setCameraPosition(LatLng(university.latitude, university.longitude));
  }

  void setCameraPosition(LatLng pos) async {
    if (mapController == null) {
      return;
    }
    mapController!.animateCamera(CameraUpdate.newLatLng(pos));
  }

  void toggleMarkerInterface(bool enabled) {
    setState(() {
      enableMarkerInterface = enabled;
    });
  }

  void toggleMarkerWindow(bool enabled) {
    setState(() {
      enableMarkerWindow = enabled;
    });
  }

  void toggleMarkerFilterOptions() {
    setState(() {
      isMarkerFilterInterfaceVisible = !isMarkerFilterInterfaceVisible;
    });
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

  void setMaximumMarkerDistance(double? value) {
    if (value == null) {
      return;
    }

    setState(() {
      maxMarkerDistance = value;
    });
  }

  void setMarkerCountLimit(double? value) {
    if (value == null) {
      return;
    }

    setState(() {
      markerCountLimit = value.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoadingMoreMarkers || isLoading,
      child: Scaffold(
        backgroundColor: Utility.tertiaryColor,
        appBar: AppBar(
          backgroundColor: Utility.primaryColor,
          title: const Text(
            "Thread Map",
            style: TextStyle(color: Utility.secondaryColor),
          ),
          actions: [
            IconButton(
              onPressed: getMapMarkers,
              icon: const Icon(
                Icons.refresh,
                color: Utility.secondaryColor,
              ),
            ),
            IconButton(
              onPressed: toggleMarkerFilterOptions,
              icon: const Icon(
                Icons.settings,
                color: Utility.secondaryColor,
              ),
            ),
          ],
        ),
        body: AbsorbPointer(
          absorbing: isLoading,
          child: isLoading
              ? Container(
                  color: Utility.tertiaryColor,
                  child: const Center(
                    child: Text(
                      "Loading. Please wait.",
                      style: TextStyle(
                          fontSize: 20, color: Utility.secondaryColor),
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
                        mapController = controller;
                        controller.setMapStyle(mapStyle);
                      },
                      onTap: (LatLng tapPosition) {
                        setState(() {
                          enableMarkerInterface = false;
                          enableMarkerWindow = false;
                        });
                      },
                      markers: markers.values.toSet(),
                    ),

                    // represents the buttons for viewing thread marker data, opening associated thread page, and closing the interface
                    Visibility(
                      visible: enableMarkerInterface,
                      child: MarkerInterface(
                        threadMapMarker: selectedThreadMapMarker,
                        toggleMarkerInterface: toggleMarkerInterface,
                        toggleMarkerWindow: toggleMarkerWindow,
                      ),
                    ),
                    // represents the information window that can be made to appear by pressing the marker data button of the marker interface
                    Visibility(
                      visible: enableMarkerWindow,
                      child: MarkerWindow(
                        threadMapMarker: selectedThreadMapMarker,
                        toggleMarkerWindow: toggleMarkerWindow,
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                    ),
                    // represents the marker filter interface
                    Visibility(
                      visible: isMarkerFilterInterfaceVisible,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          color: Utility.primaryColor,
                          child: ListView(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Marker Filters",
                                      style: TextStyle(
                                        color: Utility.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: toggleMarkerFilterOptions,
                                    icon: const Icon(
                                      Icons.close,
                                      color: Utility.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              // university dropdown button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.school,
                                      color: Utility.secondaryColor,
                                    ),
                                  ),
                                  Container(
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
                                          color: Utility.secondaryColor,
                                          overflow: TextOverflow.ellipsis),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Utility.secondaryColor,
                                      ),
                                      iconSize: 1,
                                      dropdownColor: Utility.primaryColor,
                                      underline: Container(
                                        height: 0,
                                      ),
                                      items: universityMenuItems,
                                      value: selectedUniversity,
                                      onChanged: selectUniversity,
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 4, 0, 4),
                                  child: DropdownMenu(
                                    inputDecorationTheme:
                                        const InputDecorationTheme(
                                            isCollapsed: true),
                                    width: MediaQuery.of(context).size.width *
                                        0.99,
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
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.directions_walk,
                                        color: Utility.secondaryColor,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 0, 0, 0),
                                        child: Text(
                                          "Maximum Marker Distance: ${maxMarkerDistance.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Utility.secondaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Slider(
                                  label: maxMarkerDistance.toString(),
                                  min: 0.1,
                                  max: 2,
                                  value: maxMarkerDistance,
                                  onChanged: setMaximumMarkerDistance,
                                  activeColor: Utility.secondaryColor,
                                  inactiveColor: Utility.tertiaryColor,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.numbers,
                                        color: Utility.secondaryColor,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 0, 0, 0),
                                        child: Text(
                                          "Maximum Marker Count: $markerCountLimit",
                                          style: const TextStyle(
                                            color: Utility.secondaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Slider(
                                  label: markerCountLimit.toString(),
                                  min: 1,
                                  max: 50,
                                  divisions: 49,
                                  value: markerCountLimit.toDouble(),
                                  onChanged: setMarkerCountLimit,
                                  activeColor: Utility.secondaryColor,
                                  inactiveColor: Utility.tertiaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            color: Utility.primaryColorTranslucent,
                          ),
                          child: TextButton(
                            onPressed: getMoreMapMarkers,
                            child: const Text(
                              "Show More",
                              style: TextStyle(
                                color: Utility.secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Visibility(
                        visible: isLoadingMoreMarkers,
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: MediaQuery.of(context).size.height * 0.25,
                          decoration: const BoxDecoration(
                            color: Utility.primaryColorTranslucent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(1),
                            ),
                          ),
                          child: const Text(
                            "Loading Markers...",
                            style: TextStyle(
                              color: Utility.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
