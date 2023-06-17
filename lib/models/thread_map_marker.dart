class ThreadMapMarker {
  int _id = -1;
  String _markerId = "";
  String _icon = "";
  double _latitude = -1;
  double _longitude = -1;
  String _decription = "";
  int _thread_id = -1;

  ThreadMapMarker.none();

  ThreadMapMarker.coordinates(double latitide, double longitude) {
    _latitude = latitide;
    _longitude = longitude;
  }
}
