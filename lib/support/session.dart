import 'dart:convert';
import 'dart:core';
import "package:cao_prototype/models/user.dart";
import 'package:cao_prototype/support/queries.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/individual.dart';
import '../models/organization.dart';
import 'server.dart';

enum LoginRoutes { MANUAL_LOGIN, AUTOMATIC_LOGIN }

abstract class Session {
  static const Map<LoginRoutes, String> loginRoutes = {
    LoginRoutes.MANUAL_LOGIN: "login",
    LoginRoutes.AUTOMATIC_LOGIN: "login/automatic"
  };
  static const String _databaseName = "credential_database.db";

  static User currentUser = User.none();
  static String identityToken =
      ""; // this is used to authenticate the client with the server and is retrived during log-in

  static Future<bool> localUserCredentialTableExists() async {
    bool result = false;

    try {
      String dbPath = join(await getDatabasesPath(), _databaseName);
      Database db = await openDatabase(dbPath);
      String query = "select * from USER_AUTHENTICATION";
      List<Map<String, Object?>> results = await db.rawQuery(query);
      // return true if there are locally saved user credentials
      result = results.isNotEmpty;
      print("Local Credentials: " + results.toString());
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
        version: 1,
      );
      String query =
          "create table USER_AUTHENTICATION (EMAIL text, PASSWORD text)";
      await credentialDb.execute(query);

      // insert the user's credentials immediately

      query =
          "insert into USER_AUTHENTICATION(EMAIL,PASSWORD) values ('$email','$password')";
      int id = await credentialDb.rawInsert(query);

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
          "update USER_AUTHENTICATION set EMAIL = '$email', PASSWORD = '$password'";
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

    return result;
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
    LoginRoutes route,
    String email,
    String password,
  ) async {
    QueryResult qr = QueryResult();

    Map<String, String> arguments = {"email": email, "password": password};

    try {
      var response =
          await Server.submitGetRequest(arguments, loginRoutes[route]!);
      Map<String, dynamic> fields = jsonDecode(response);
      qr.result = fields["result"];
      print(fields);

      // exit if the server failed to login the user
      if (qr.result == false) {
        qr.message = fields["message"];
        return qr;
      }

      Map<String, dynamic> data = fields["data"];

      if (fields["account_role"] == "organization") {
        Session.currentUser = Organization.all(
          data["id"],
          data["email"],
          data["password"],
          data["alias"],
          data["name"],
        );
      } else {
        Session.currentUser = Individual.all(
            data["id"],
            data["email"],
            data["password"],
            data["alias"],
            data["first_name"],
            data["last_name"]);
      }

      Session.identityToken = fields["identity_token"];
      qr.data = Session.currentUser;

      // if the login was done manually and completed successfully, then locally save the user's credentials
      if (route == LoginRoutes.MANUAL_LOGIN) {
        qr.result = await Session.saveUserCredentialsLocally(
          Session.currentUser.email,
          Session.currentUser.password,
        );
      }
    } catch (e) {
      print("Error in Session.login(): $e");
      qr.result = false;
    }
    print(qr);
    return qr;
  }

  static Future<QueryResult> loginWithSavedCredentials() async {
    QueryResult qr = QueryResult();

    // attempt to get locally saved user credentials
    Map<String, Object?> credentials = await Session.getLocalUserCredentials();
    if (credentials.isEmpty) {
      qr.result = false;
      qr.message =
          "Failed to read locally saved credentials. Please manually sign in.";
      print(qr);
      return qr;
    }

    if (credentials["EMAIL"] != null && credentials["PASSWORD"] != null) {
      qr = await Session.login(
        LoginRoutes.AUTOMATIC_LOGIN,
        credentials["EMAIL"].toString(),
        credentials["PASSWORD"].toString(),
      );

      print("2A " + qr.toString());

      if (qr.result == false) {
        qr.message = "Failed to authenticate user. Please manually sign in.";
      }
    }

    return qr;
  }
}
