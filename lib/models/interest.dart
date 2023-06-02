import 'dart:convert';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';

class Interest {
  int _id = -1;
  int _universityId = -1;
  String _name = "";
  Interest.none();
  Interest.all(int id, int universityId, String name) {
    _id = id;
    _universityId = universityId;
    _name = name;
  }

  int getId() {
    return _id;
  }

  int getUniversityId() {
    return _universityId;
  }

  String getName() {
    return _name;
  }

  @override
  String toString() {
    return _name;
  }

  Map<String, dynamic> toMap() {
    return {"id": _id, "university_id": _universityId, "name": _name};
  }

  // returns a list of interests that are associated to a specified university
  static getInterests(int universityId) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "university_id": universityId.toString()
      };
      var response =
          await Server.submitGetRequest(arguments, "fetch/interests");
      Map<String, dynamic> fields = jsonDecode(response);

      if (fields["result"] == false) {
        throw Exception();
      }

      List<Interest> interests = List.empty(growable: true);

      for (var item in fields["data"]) {
        interests
            .add(Interest.all(item["id"], item["university_id"], item["name"]));
      }

      qr.data = interests;
      qr.result = true;
    } catch (e) {
      print("Error in Interest.getInterests(): $e");
    }

    return qr;
  }
}
