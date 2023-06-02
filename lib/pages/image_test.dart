import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cao_prototype/support/utility.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageTestPage extends StatefulWidget {
  const ImageTestPage({super.key});

  @override
  State<ImageTestPage> createState() => _ImageTestPageState();
}

class _ImageTestPageState extends State<ImageTestPage> {
  String path = "";
  String b64 = "";

  void attachFiles() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);

    if (result != null) {
      if (result.paths.isNotEmpty) {
        path = result.paths[0]!;
        setState(() {
          path;
        });
        File file = File(path);
        int length = await file.length();
        print("File size: " + length.toString());

        // encode file
        Uint8List byteList = await file.readAsBytes();
        Uint8List? compressedByteList =
            await FlutterImageCompress.compressWithList(byteList, quality: 1);

        if (compressedByteList == null) {
          return;
        }
        print("Original length: " + byteList.length.toString());
        print("Compressed length 1: " + compressedByteList.length.toString());

        String base64Data = base64Encode(compressedByteList);

        setState(() {
          b64 = base64Data;
        });

        // decode base 64 string and recreate the file
        Image img = Image.memory(base64Decode(base64Data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Test Page")),
      body: Column(children: [
        IconButton(
            onPressed: attachFiles,
            icon: const Icon(
              Icons.attach_file,
              color: Utility.primaryColor,
            )),
        /*
        if (path.isNotEmpty)
          Container(
            color: Utility.primaryColor,
            child: Image.memory(base64Decode(b64)),
          ),
          */
      ]),
    );
  }
}
