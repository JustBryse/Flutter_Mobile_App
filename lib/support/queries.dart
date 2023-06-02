import 'package:mysql1/mysql1.dart';

abstract class Queries {
  // MySQL ClearDB database associated to heroku cao-prototype app
  static const String _database = "`heroku_25147447fb20cd7`";
  static const String _host = "us-cdbr-east-06.cleardb.net";
  static const String _user = "ba8a84873b2bd6";
  static const String _password = "951badc7";
  static const int _port = 3306;

  static getConnection() async {
    try {
      var con = await MySqlConnection.connect(ConnectionSettings(
          host: _host, user: _user, port: _port, password: _password));

      String query = "use " + _database + ";";
      await con.query(query);
      return con;
    } catch (e) {
      print("Exception in Queries.getConnection(): " + e.toString());
    }
  }
}

class QueryResult {
  var data;
  bool result = false;
  String message = "";

  @override
  String toString() {
    // TODO: implement toString
    return {"data": data, "result": result, "message": message}.toString();
  }
}
