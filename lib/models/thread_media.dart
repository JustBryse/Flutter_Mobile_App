import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/models/thread_media_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ThreadMedia {
  // these ID variables will only ever be set when fetching media data from the back-end
  int _id = -1;
  int _threadId = -1;
  // contains info about the file where the media comes from (name, extension, path)
  ThreadMediaFile _file = ThreadMediaFile.none();
  // byte list data that is used to construct UI media
  Uint8List _bytes = Uint8List(0);
  bool _hasBytes = false;
  String _s3ObjectUrl = "";
  bool _hasUrl = false;

  String get name => _file.name;
  String get extension => _file.extension;
  String get path => _file.path;
  Uint8List get bytes => _bytes;
  String get base64Data => base64Encode(_bytes);
  bool get hasBytes => _hasBytes;
  String get s3ObjectUrl => _s3ObjectUrl;
  bool get hasUrl => _hasUrl;

  @override
  String toString() {
    return {"name": name, "path": path}.toString();
  }

  // used when creating thread media during thread creation
  ThreadMedia.create(ThreadMediaFile threadMediaFile) {
    _file = threadMediaFile;
  }

  // used when fetching thread media from the back-end
  ThreadMedia.fetchWithBase64(
      int id, String name, String base64Data, int threadId) {
    _id = id;
    _file = ThreadMediaFile.name(name);
    _bytes = base64Decode(base64Data);
    _hasBytes = true;
    _threadId = threadId;
  }

  // used when fetching thread media from the back-end
  ThreadMedia.fetchWithUrl(
      int id, String name, String s3ObjectUrl, int threadId) {
    _id = id;
    _file = ThreadMediaFile.name(name);
    _s3ObjectUrl = s3ObjectUrl;
    _hasUrl = true;
    _threadId = threadId;
  }

  // used for picking files locally and converting to a byte list
  static Future<Uint8List> getBytesFromPath(String path) async {
    return await File(path).readAsBytes();
  }

  // used for picking files locally and converting to a compressed byte list
  static Future<Uint8List> getCompressedBytesFromPath(
      String path, int compression) async {
    Uint8List fileBytes = await File(path).readAsBytes();
    return await FlutterImageCompress.compressWithList(fileBytes,
        quality: compression);
  }

  // This function does not check if base 64 media data has been computed. That check should be done externally
  Image getImageFromBytes(double width, double height, BoxFit boxFit) {
    return Image.memory(
      _bytes,
      fit: boxFit,
      width: width,
      height: height,
    );
  }

  // This function returns an image by using the
  Image getImageFromUrl(double width, double height, BoxFit boxFit) {
    return Image.network(
      s3ObjectUrl,
      fit: boxFit,
      width: width,
      height: height,
    );
  }
}
