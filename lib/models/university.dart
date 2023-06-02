import 'dart:convert';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';

class University {
  int _id = -1;
  String _name = "";

  University.none();
  University.all(int id, String name) {
    _id = id;
    _name = name;
  }

  int getId() {
    return _id;
  }

  String getName() {
    return _name;
  }

  @override
  String toString() {
    // TODO: implement toString
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
        universities.add(University.all(item["id"], item["name"]));
      }

      qr.data = universities;
      qr.result = true;
    } catch (e) {
      print("Error in University.getUniversities(): $e");
    }
    return qr;
  }
}
