import 'dart:io';
import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:cao_prototype/pages/dashboard/feed/create_thread/models/thread_media_file.dart';

class ThreadMediaWidget extends StatefulWidget {
  ThreadMediaFile _file = ThreadMediaFile.all("", "", "");
  ThreadMediaFile get file => _file;
  String get name => _file.name;

  Function(ThreadMediaWidget) _removeThreadMedia = (p0) {};

  ThreadMediaWidget(
      {Key? key,
      required ThreadMediaFile file,
      required Function(ThreadMediaWidget) removeThreadMedia})
      : super(key: key) {
    _file = file;
    _removeThreadMedia = removeThreadMedia;
  }

  @override
  State<ThreadMediaWidget> createState() => _ThreadMediaWidgetState();
}

class _ThreadMediaWidgetState extends State<ThreadMediaWidget> {
  removeThreadMedia() {
    widget._removeThreadMedia(widget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Utility.primaryColor,
          border: Border.all(
            color: Utility.primaryColor,
            width: 0.5, //width of border
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Image.file(
                File(widget._file.path),
                width: 100,
                height: 100,
              ),
            ),
            /*
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: Text(
                widget.name,
                style: const TextStyle(color: Utility.secondaryColor),
              ),
            ),
            */
            IconButton(
              onPressed: removeThreadMedia,
              icon: const Icon(
                Icons.cancel,
                color: Utility.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
