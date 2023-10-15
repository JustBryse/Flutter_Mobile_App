import 'dart:convert';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';
import 'package:cao_prototype/support/time_utility.dart';
import 'package:crypto/crypto.dart';

// individuals are usually students, organizations are typically businesses or sponsors, and associations are campus clubs
enum AccountTypes { UNSPECIFIED, INDIVIDUAL, ORGANIZATION, ASSOCIATION }

// top level class of all inheriting account classes
class User {
  static const Map<AccountTypes, int> _accountTypeCodes = {
    AccountTypes.UNSPECIFIED: -1,
    AccountTypes.INDIVIDUAL: 0,
    AccountTypes.ORGANIZATION: 1,
    AccountTypes.ASSOCIATION: 2,
  };

  int _id = -1;
  String _email = "";
  String _password = "";
  String _alias = "Anonymous";
  DateTime _insertDate = DateTime(0);
  DateTime _editDate = DateTime(0);

  int get id => _id;
  String get email => _email;
  String get password => _password;
  String get alias => _alias;
  DateTime get insertDate => _insertDate;
  DateTime get editDate => _editDate;

  User.none();
  User.noTimeStamps(int id, String email, String password, String alias) {
    _id = id;
    _email = email;
    _password = password;
    _alias = alias;
  }

  // a constructor that
  User.all(
    int id,
    String email,
    String password,
    String alias,
    DateTime insertDate,
    DateTime editDate,
  ) {
    _id = id;
    _email = email;
    _password = password;
    _alias = alias;
    _insertDate = insertDate;
    _editDate = editDate;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": _id,
      "email": _email,
      "password": _password,
      "alias": _alias,
      "insert_date": TimeUtility.getIsoDateTime(insertDate),
      "edit_date": TimeUtility.getIsoDateTime(editDate),
    };
  }

  @override
  String toString() {
    return toMap.toString();
  }

  bool _equals(Object other) {
    if (other is User == false) {
      return false;
    }
    User u = other as User;
    return id == u.id;
  }

  @override
  bool operator ==(Object other) => _equals(other);
  @override
  int get hashCode => (id.toString()).hashCode;

  static int getAccountTypeCode(AccountTypes at) {
    return _accountTypeCodes[at]!;
  }

  // returns a list of users who have an alias that is similar to the provided "pattern" argument
  static Future<QueryResult> getUsersByAlias(String pattern) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, dynamic> arguments = {"alias_pattern": pattern};
      var response = await Server.submitGetRequest(arguments, "fetch/users_1");
      var fields = jsonDecode(response);
      qr.result = fields["result"];
      qr.resultCode = fields["result_code"];
      qr.message = fields["message"];
      if (qr.result == false) {
        return qr;
      }

      List<User> users = List.empty(growable: true);

      for (var userField in fields["users"]) {
        DateTime editDate = TimeUtility.getDateTimeFromFormattedPattern(
          userField["edit_date"],
        );
        DateTime insertDate = TimeUtility.getDateTimeFromFormattedPattern(
          userField["insert_date"],
        );

        users.add(
          User.all(
            userField["id"],
            userField["email"],
            userField["password"],
            userField["alias"],
            insertDate,
            editDate,
          ),
        );
      }

      qr.data = users;
    } catch (e) {
      print("Error in User.getUsersByAlias(): " + e.toString());
      qr.result = false;
      qr.resultCode = -1;
    }

    return qr;
  }
}
