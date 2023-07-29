import 'dart:convert';
import 'dart:core';
import "package:cao_prototype/models/user.dart";
import 'package:cao_prototype/support/queries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/individual.dart';
import '../models/organization.dart';
import 'server.dart';

abstract class Session {
  static const String _databaseName = "credential_database.db";

  static User currentUser = User.none();

  static Future<bool> localUserCredentialTableExists() async {
    bool result = false;

    try {
      String dbPath = join(await getDatabasesPath(), _databaseName);
      Database db = await openDatabase(dbPath);
      String query = "select * from USER_AUTHENTICATION";
      List<Map<String, Object?>> results = await db.rawQuery(query);
      // return true if there are locally saved user credentials
      result = results.isNotEmpty;
    } catch (e) {
      print("Error in Session.localUserCredentialTableExists(): $e");
      result = false;
    }

    return result;
  }

  static Future<bool> createLocalCredentialDatabase(
    String dbPath,
    String email,
    String password,
  ) async {
    bool result = false;
    try {
      // create database to store user credentials
      Database credentialDb = await openDatabase(
        dbPath,
        onCreate: (db, version) async {
          String query =
              "create table USER_AUTHENTICATION (EMAIL varchar(255), PASSWORD varchar(255))";
          await db.execute(query);
        },
        version: 1,
      );

      // insert the user's credentials immediately
      int resultCode = await credentialDb.insert(
        "USER_AUTHENTICATION",
        {"EMAIL": email, "PASSWORD": password},
      );

      result = true;
    } catch (e) {
      print("Error in Session.createLocalCredentialDatabase(): $e");
      result = false;
    }
    return result;
  }

  static Future<bool> updateLocalUserCredentials(
    String dbPath,
    String email,
    String password,
  ) async {
    bool result = false;
    try {
      Database db = await openDatabase(dbPath);
      String query =
          "update USER_AUTHENTICATION set EMAIL = '$email', set PASSWORD = '$password'";
      int affectedRowCount = await db.rawUpdate(query);
      result = affectedRowCount > 0;
    } catch (e) {
      print("Error in updateLocalUserCredentials(): $e");
      result = false;
    }

    return result;
  }

  static Future<bool> saveUserCredentialsLocally(
    String email,
    String password,
  ) async {
    String dbPath = join(await getDatabasesPath(), _databaseName);

    bool result = false;

    if (await localUserCredentialTableExists() == false) {
      // create SQL database and table if it doesn't already exist, and simultaneously insert the user's credentials
      result = await createLocalCredentialDatabase(dbPath, email, password);
    } else {
      // update SQL table with new credentials if it does exist
      result = await updateLocalUserCredentials(dbPath, email, password);
    }

    return true;
  }

  static Future<Map<String, Object?>> getLocalUserCredentials() async {
    Map<String, Object?> credentials = {};

    try {
      String dbPath = join(await getDatabasesPath(), _databaseName);
      Database db = await openDatabase(dbPath);
      String query = "select * from USER_AUTHENTICATION";
      List<Map<String, Object?>> results = await db.rawQuery(query);

      if (results.isNotEmpty) {
        credentials = results[0];
      }
    } catch (e) {
      print("Error in Session.getLocalUserCredentials():$e");
      credentials.clear();
    }

    return credentials;
  }

  static Future<QueryResult> login(
      String httpRoute, String email, String password) async {
    QueryResult qr = QueryResult();
    Map<String, String> arguments = {"email": email, "password": password};

    try {
      var response = await Server.submitGetRequest(arguments, httpRoute);
      Map<String, dynamic> fields = jsonDecode(response);

      // exit if the server failed to login the user
      if (fields["result"] == false) {
        qr.message = fields["message"];
        qr.result = false;
        return qr;
      }

      Map<String, dynamic> data = fields["data"];

      if (fields["account_role"] == "organization") {
        Session.currentUser = Organization.all(data["id"], data["email"],
            data["password"], data["alias"], data["name"]);
      } else {
        Session.currentUser = Individual.all(
            data["id"],
            data["email"],
            data["password"],
            data["alias"],
            data["first_name"],
            data["last_name"]);
      }
      qr.result = true;
      qr.data = Session.currentUser;
    } catch (e) {
      print("Error in Session.login(): $e");
      qr.result = false;
    }

    return qr;
  }
}
