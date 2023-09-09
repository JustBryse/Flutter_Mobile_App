import 'dart:convert';
import 'package:cao_prototype/support/queries.dart';
import 'package:crypto/crypto.dart';

// individuals are usually students, organizations are typically businesses or sponsors, and associations are campus clubs
enum AccountTypes { INDIVIDUAL, ORGANIZATION, ASSOCIATION }

// top level class of all inheriting account classes
class User {
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
      "insert_date": _insertDate.toIso8601String(),
      "edit_date": _editDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return toMap.toString();
  }
}
