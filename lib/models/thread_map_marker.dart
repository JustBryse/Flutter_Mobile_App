import 'package:cao_prototype/models/thread.dart';

class ThreadMapMarker {
  int _id = -1;
  String _markerId = "";
  String _icon = "";
  double _latitude = -1;
  double _longitude = -1;
  String _decription = "";
  int _threadId = -1;

  int get id => _id;
  String get markerId => _markerId;
  String get icon => _icon;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get description => _decription;
  int get threadId => _threadId;

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
      "latitude": _latitude,
      "longitude": _longitude,
      "description": _decription,
      "thread_id": _threadId
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
