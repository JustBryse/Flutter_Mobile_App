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

enum ResultCodeKeys {
  UNKNOWN,
  NONE,
  UNAUTHORIZED,
  FORBIDDEN,
  SUCCESS,
  INTERNAL_SERVER_ERROR
}

abstract class ResultCodes {
  static const Map<ResultCodeKeys, int> _codes = {
    ResultCodeKeys.UNKNOWN: -1,
    ResultCodeKeys.NONE: 0,
    ResultCodeKeys.UNAUTHORIZED: 401,
    ResultCodeKeys.FORBIDDEN: 403,
    ResultCodeKeys.SUCCESS: 200,
    ResultCodeKeys.INTERNAL_SERVER_ERROR: 500,
  };

  static const Map<int, ResultCodeKeys> _codesReversed = {
    -1: ResultCodeKeys.UNKNOWN,
    0: ResultCodeKeys.NONE,
    401: ResultCodeKeys.UNAUTHORIZED,
    403: ResultCodeKeys.FORBIDDEN,
    200: ResultCodeKeys.SUCCESS,
    500: ResultCodeKeys.INTERNAL_SERVER_ERROR,
  };

  static int get UNKNOWN => _codes[ResultCodeKeys.UNKNOWN]!;
  static int get NONE => _codes[ResultCodeKeys.NONE]!;
  static int get UNAUTHORIZED => _codes[ResultCodeKeys.UNAUTHORIZED]!;
  static int get FORBIDDEN => _codes[ResultCodeKeys.FORBIDDEN]!;
  static int get SUCCESS => _codes[ResultCodeKeys.SUCCESS]!;
  static int get INTERNAL_SERVER_ERROR =>
      _codes[ResultCodeKeys.INTERNAL_SERVER_ERROR]!;

  static int getCodeValue(ResultCodeKeys key) {
    return _codes[key]!;
  }

  static ResultCodeKeys getCodeKey(int value) {
    return _codesReversed[value]!;
  }
}

class QueryResult {
  var data;
  bool result = false;
  int resultCode = -1;
  String message = "";

  @override
  String toString() {
    // TODO: implement toString
    return {
      "data": data,
      "result": result,
      "resultCode": resultCode,
      "message": message
    }.toString();
  }
}
