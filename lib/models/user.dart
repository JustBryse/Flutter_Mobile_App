import 'dart:convert';
import 'package:cao_prototype/support/queries.dart';
import 'package:crypto/crypto.dart';

// individuals are typically students, organizations are typically businesses or sponsors, and associations are campus clubs
enum AccountTypes { INDIVIDUAL, ORGANIZATION, ASSOCIATION }

// top level class of all inheriting account classes
class User {
  int _id = -1;
  String _email = "";
  String _password = "";
  String _alias = "Anonymous";

  int get id => _id;
  String get email => _email;
  String get password => _password;
  String get alias => _alias;

  User.none();
  User.all(int id, String email, String password, String alias) {
    _id = id;
    _email = email;
    _password = password;
    _alias = alias;
  }

  // hashes a password
  static String getHashedPassword(String password) {
    List<int> encodedPassword = utf8.encode(password);
    Digest hashedPassword = sha256.convert(encodedPassword);
    return hashedPassword.toString();
  }

  @override
  String toString() {
    // TODO: implement toString
    return {"id": _id, "email": _email, "password": _password, "alias": _alias}
        .toString();
  }
}
