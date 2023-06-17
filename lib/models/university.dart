import 'dart:convert';
import 'dart:ffi';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';

class University {
  int _id = -1;
  String _name = "";
  String _codeName = "";
  double _latitude = -1;
  double _longitude = -1;

  int get id => _id;
  String get name => _name;
  String get codeName => _codeName;
  double get latitude => _latitude;
  double get longitude => _longitude;

  University.none();
  University.label(int id, String name) {
    _id = id;
    _name = name;
  }

  University.all(
      int id, String name, String codeName, double latitude, double longitude) {
    _id = id;
    _name = name;
    _codeName = codeName;
    _latitude = latitude;
    _longitude = longitude;
  }

  int getId() {
    return _id;
  }

  String getName() {
    return _name;
  }

  @override
  String toString() {
    return _name;
  }

  // get a list of all the universities
  static getUniversities() async {
    QueryResult qr = QueryResult();
    try {
      var response =
          await Server.submitGetRequest({"": ""}, "fetch/universities");
      Map<String, dynamic> fields = jsonDecode(response);

      if (fields["result"] == false) {
        throw Exception();
      }

      List<University> universities = List.empty(growable: true);

      for (var item in fields["data"]) {
        universities.add(
          University.all(
            item["id"],
            item["name"],
            item["code_name"],
            // note that latitude and longitude are returned as type String from the back end due to JSON serialization issues with the decimal type
            double.parse(item["latitude"]),
            double.parse(item["longitude"]),
          ),
        );
      }

      qr.data = universities;
      qr.result = true;
    } catch (e) {
      print("Error in University.getUniversities(): $e");
    }
    return qr;
  }
}
