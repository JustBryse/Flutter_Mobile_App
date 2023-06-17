import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ImageUriTest extends StatefulWidget {
  const ImageUriTest({super.key});

  @override
  State<ImageUriTest> createState() => _ImageUriTestState();
}

class _ImageUriTestState extends State<ImageUriTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Column(
            children: [
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
              Image.network("https://picsum.photos/id/237/200/300"),
            ],
          ),
        ],
      ),
    );
  }
}
