import 'dart:convert';

import 'package:cao_prototype/models/thread.dart';
import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';

import '../support/time_utility.dart';

class ThreadMapMarker {
  int _id = -1;
  String _markerId = "";
  String _icon = "";
  double _latitude = -1;
  double _longitude = -1;
  String _decription = "";
  int _threadId = -1;
  User _creator = User.none();

  int get id => _id;
  String get markerId => _markerId;
  String get icon => _icon;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get description => _decription;
  int get threadId => _threadId;
  User get creator => _creator;

  ThreadMapMarker.none();

  ThreadMapMarker.coordinates(double latitide, double longitude) {
    _latitude = latitide;
    _longitude = longitude;
  }

  ThreadMapMarker.fetch(int id, String markerId, String icon, double latitude,
      double longitude, String description, int threadId) {
    _id = id;
    _markerId = markerId;
    _icon = icon;
    _latitude = latitude;
    _longitude = longitude;
    _decription = description;
    _threadId = threadId;
  }

  ThreadMapMarker.fetchWithCreator(
      int id,
      String markerId,
      String icon,
      double latitude,
      double longitude,
      String description,
      int threadId,
      User creator) {
    _id = id;
    _markerId = markerId;
    _icon = icon;
    _latitude = latitude;
    _longitude = longitude;
    _decription = description;
    _threadId = threadId;
    _creator = creator;
  }

  ThreadMapMarker.create(String markerId, String icon, double latitude,
      double longitude, String description) {
    _markerId = markerId;
    _icon = icon;
    _latitude = latitude;
    _longitude = longitude;
    _decription = description;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": _id,
      "marker_id": _markerId,
      "icon": _icon,
      "latitude": _latitude.toString(),
      "longitude": _longitude.toString(),
      "description": _decription,
      "thread_id": _threadId
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  // This function sends a GET request for map markers
  static Future<QueryResult> getFilteredThreadMapMarkers(
    List<int> threadMapMarkerIds,
    int universityId,
    double distance,
    DateTime lowerDate,
    int markerCountLimit,
    bool includeMarkerCreator,
  ) async {
    QueryResult qr = QueryResult();
    try {
      String lowerDateFormatted = TimeUtility.getIsoDateTime(lowerDate);
      Map<String, String> arguments = {
        "thread_marker_ids": jsonEncode(threadMapMarkerIds),
        "university_id": jsonEncode(universityId),
        "lower_date": lowerDateFormatted,
        "distance": jsonEncode(distance),
        "include_creator": jsonEncode(includeMarkerCreator),
        "marker_count_limit": jsonEncode(markerCountLimit)
      };
      /* One of the two http response wrapper functions is selected here because the http response will be handled differently 
      depending on whether the map-marker-creator information is requested in addition to the map marker data. */
      if (includeMarkerCreator) {
        qr = await _getFilteredThreadMapMarkersWithCreator(arguments);
      } else {
        qr = await _getFilteredThreadMapMarkersWithoutCreator(arguments);
      }
    } catch (e) {
      qr.message = "Error in ThreadMapMarker.getFilteredThreadMapMarkers(): $e";
    }
    return qr;
  }

  // wrapper function used by getFilteredThreadMapMarkers()
  static Future<QueryResult> _getFilteredThreadMapMarkersWithCreator(
      Map<String, String> arguments) async {
    QueryResult qr = QueryResult();
    try {
      var response = await Server.submitGetRequest(
          arguments, "fetch/filtered_thread_markers");
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.message = fields["message"];

      // if something went wrong then exit here
      if (qr.result == false) {
        return qr;
      }

      List<ThreadMapMarker> threadMapMarkers = List.empty(growable: true);

      for (var mm in fields["map_markers"]) {
        // get creator data
        User creator = User.all(
          mm["creator"]["id"],
          mm["creator"]["email"],
          mm["creator"]["password"],
          mm["creator"]["alias"],
        );

        // get map marker data
        ThreadMapMarker threadMapMarker = ThreadMapMarker.fetchWithCreator(
          mm["id"],
          mm["marker_id"],
          mm["icon"],
          double.parse(mm["latitude"].toString()),
          double.parse(mm["longitude"].toString()),
          mm["description"],
          mm["thread_id"],
          creator,
        );

        threadMapMarkers.add(threadMapMarker);
      }

      qr.data = threadMapMarkers;
    } catch (e) {
      qr.message =
          "Error in ThreadMapMarker._getFilteredThreadMapMarkersWithCreator(): $e";
      qr.result = false;
    }

    return qr;
  }

  // wrapper function used by getFilteredThreadMapMarkers()
  static Future<QueryResult> _getFilteredThreadMapMarkersWithoutCreator(
      Map<String, String> arguments) async {
    QueryResult qr = QueryResult();
    try {} catch (e) {
      qr.message =
          "Error in ThreadMapMarker._getFilteredThreadMapMarkersWithoutCreator(): $e";
    }
    return qr;
  }

  static Future<QueryResult> getThreadMapMarkers(
      int markerCountLimit, bool includeMarkerCreator) async {
    QueryResult qr = QueryResult();
    try {
      if (includeMarkerCreator) {
        qr = await _getThreadMapMarkersWithCreator(markerCountLimit);
      } else {
        qr = await _getThreadMapMarkersWithoutCreator(markerCountLimit);
      }
    } catch (e) {
      qr.message = "Error in ThreadMapMarker.getThreadMapMarkers():$e";
    }

    return qr;
  }

  static Future<QueryResult> _getThreadMapMarkersWithCreator(
      int markerCountLimit) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "include_creator": true.toString(),
        "marker_count_limit": markerCountLimit.toString()
      };

      var response =
          await Server.submitGetRequest(arguments, "fetch/thread_markers");
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.message = fields["message"];

      // if something went wrong then exit here
      if (qr.result == false) {
        return qr;
      }

      List<ThreadMapMarker> threadMapMarkers = List.empty(growable: true);

      for (var mm in fields["map_markers"]) {
        // get creator data
        User creator = User.all(
          mm["creator"]["id"],
          mm["creator"]["email"],
          mm["creator"]["password"],
          mm["creator"]["alias"],
        );

        // get map marker data
        ThreadMapMarker threadMapMarker = ThreadMapMarker.fetchWithCreator(
          mm["id"],
          mm["marker_id"],
          mm["icon"],
          double.parse(mm["latitude"].toString()),
          double.parse(mm["longitude"].toString()),
          mm["description"],
          mm["thread_id"],
          creator,
        );

        threadMapMarkers.add(threadMapMarker);
      }

      qr.data = threadMapMarkers;
    } catch (e) {
      qr.message =
          "Error in ThreadMapMarker._getThreadMapMarkersWithCreator():$e";
      qr.result = false;
    }

    return qr;
  }

  static Future<QueryResult> _getThreadMapMarkersWithoutCreator(
      int markerCountLimit) async {
    QueryResult qr = QueryResult();
    try {} catch (e) {
      qr.message =
          "Error in ThreadMapMarker._getThreadMapMarkersWithoutCreator():$e";
    }

    return qr;
  }
}
