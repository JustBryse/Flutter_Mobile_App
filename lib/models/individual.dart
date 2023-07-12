import 'package:cao_prototype/models/user.dart';
import 'package:cao_prototype/models/interest.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'dart:convert';

class Individual extends User {
  String _firstName = "";
  String _lastName = "";

  String get firstName => _firstName;
  String get lastName => _lastName;

  Individual.all(int id, String email, String password, String alias,
      String firstName, String lastName)
      : super.all(id, email, password, alias) {
    _firstName = firstName;
    _lastName = lastName;
  }

  static registerIndividual(String email, String password, String alias,
      String firstName, String lastName, List<Interest> interests) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {
        "email": email,
        "password": password,
        "alias": alias,
        "first_name": firstName,
        "last_name": lastName,
      };

      List<Map<String, dynamic>> mappedInterests = List.empty(growable: true);
      for (int i = 0; i < interests.length; ++i) {
        mappedInterests.add(interests[i].toMap());
      }

      arguments["interests"] = jsonEncode(mappedInterests);

      var response =
          await Server.submitGetRequest(arguments, "register/individual");
      Map<String, dynamic> fields = jsonDecode(response);

      qr.result = fields["result"];
      qr.message = fields["message"];
    } catch (e) {
      print("Error in Individual.registerIndividual(): $e");
    }

    return qr;
  }
}
