import 'dart:convert';

import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/server.dart';

class ChatbotQueries {
  static Future<QueryResult> queryChatbot(
      int userId, int universityId, String pattern) async {
    QueryResult qr = QueryResult();
    try {
      Map<String, String> arguments = {
        "user_id": userId.toString(),
        "university_id": universityId.toString(),
        "pattern": pattern
      };

      var response =
          await Server.submitGetRequest(arguments, "chatbot/request");
      Map<String, dynamic> fields = jsonDecode(response);

      qr.result = fields["result"];

      if (qr.result == false) {
        return qr;
      }

      qr.message = fields["message"];

      qr.data = {
        "prediction": fields["prediction"],
        "response": fields["response"]
      };
    } catch (e) {
      qr.result = false;
      print("Error in ChatbotQueries.queryChatbot(): $e");
    }

    return qr;
  }
}
