import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cao_prototype/models/thread.dart';
import 'package:cao_prototype/models/thread_media.dart';
import 'package:cao_prototype/support/queries.dart';
import 'package:cao_prototype/support/session.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

abstract class Server {
  static const int uploadDataLimit = 1048576; // one megabyte or 2^20 bytes
  static const String url = "cao-prototype.herokuapp.com";

  static submitGetRequest(Map<String, dynamic> arguments, String path) async {
    arguments["user_id"] = jsonEncode(Session.currentUser.id);

    var client = http.Client();
    Uri uri = Uri.https(url, path, arguments);
    var response = await client.get(
      uri,
      headers: {
        "Identity-Token": Session.identityToken,
      },
    );
    return response.body;
  }

  static submitPostRequest(Map<String, dynamic> arguments, String path) async {
    arguments["user_id"] = Session.currentUser.id;

    var client = http.Client();

    Uri uri = Uri.https(url, path);

    var response = await client.post(
      uri,
      body: jsonEncode(arguments),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
        "Referer": "https://heroku.com",
        "Identity-Token": Session.identityToken,
        "Is-Multipart": jsonEncode(false),
      },
    );
    print(response.body);
    return response.body;
  }

  // don't forget to json-encode the map parameter arguments' values before passing to this function
  static submitThreadPostRequest(
    Map<String, String> arguments,
    List<ThreadMedia> threadMedia,
    String path,
  ) async {
    arguments["user_id"] = jsonEncode(Session.currentUser.id);

    Uri uri = Uri.https(url, path);
    print(arguments);

    int fileUploadSize = 0;

    List<http.MultipartFile> multiPartFiles = List.empty(growable: true);

    for (int i = 0; i < threadMedia.length; ++i) {
      ThreadMedia media = threadMedia[i];
      String fileKey = "file$i";
      List<int> bytes = await ThreadMedia.getCompressedBytesFromPath(
        media.path,
        10,
      );

      fileUploadSize += bytes.length;

      http.MultipartFile mpf = http.MultipartFile.fromBytes(
        fileKey,
        bytes,
        filename: media.name,
      );
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
        "Referer": "https://heroku.com",
        "Is-Multipart": jsonEncode(true),
        "Identity-Token": Session.identityToken
      })
      ..fields.addAll(arguments)
      ..files.addAll(multiPartFiles);

    http.StreamedResponse streamedResponse = await request.send();
    http.Response response = await http.Response.fromStream(streamedResponse);

    return response.body;
  }
}
