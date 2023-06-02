import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cao_prototype/models/thread.dart';
import 'package:cao_prototype/models/thread_media.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

abstract class Server {
  static const int uploadDataLimit = 1048576; // one megabyte or 2^20 bytes
  static const String url = "cao-prototype.herokuapp.com";

  static submitGetRequest(Map<String, dynamic> arguments, String path) async {
    var client = http.Client();
    Uri uri = Uri.https(url, path, arguments);
    var response = await client.get(uri);
    return response.body;
  }

  static submitPostRequest(Map<String, dynamic> arguments, String path) async {
    var client = http.Client();

    Uri uri = Uri.https(url, path);
    var response =
        await client.post(uri, body: jsonEncode(arguments), headers: {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      "Referer": "https://heroku.com"
    });
    return response.body;
  }

  // don't forget to json-encode the map parameter arguments' values before passing to this function
  static submitThreadPostRequest(Map<String, String> arguments,
      List<ThreadMedia> threadMedia, String path) async {
    Uri uri = Uri.https(url, path);

    int fileUploadSize = 0;

    List<http.MultipartFile> multiPartFiles = List.empty(growable: true);

    for (int i = 0; i < threadMedia.length; ++i) {
      ThreadMedia media = threadMedia[i];
      String fileKey = "file$i";
      List<int> bytes =
          await ThreadMedia.getCompressedBytesFromPath(media.path, 10);

      fileUploadSize += bytes.length;

      http.MultipartFile mpf =
          http.MultipartFile.fromBytes(fileKey, bytes, filename: media.name);
      multiPartFiles.add(mpf);
    }

    // abort if the attached files exceed the upload limit
    if (fileUploadSize > uploadDataLimit) {
      return {
        "result": false,
        "message": "Attached files exceed upload data limit"
      };
    }

    var request = http.MultipartRequest("POST", uri)
      ..headers.addAll({
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "Referer": "https://heroku.com"
      })
      ..fields.addAll(arguments)
      ..files.addAll(multiPartFiles);

    print("Large post request fields: " + request.fields.toString());

    print("Large Request: " + request.toString());

    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);
    print("Result: ${response.statusCode}");
    return response.body;
  }
}

class ServerResponse {
  int statusCode;
  bool result;
  String message;
  var data;
  ServerResponse.all(this.statusCode, this.result, this.message, this.data);
}
