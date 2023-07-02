import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ImageUriTest extends StatefulWidget {
  const ImageUriTest({super.key});

  @override
  State<ImageUriTest> createState() => _ImageUriTestState();
}

class _ImageUriTestState extends State<ImageUriTest> {
  TextEditingController imageTEC = TextEditingController();

  List<Image> images = List.empty(growable: true);

  void addImage() {
    try {
      images.add(Image.network(imageTEC.text));
    } catch (e) {
      Utility.displayAlertMessage(context, "Failed to Add Image", "");
    }

    imageTEC.text = "";
    setState(() {
      imageTEC;
      images;
    });
  }

//https://picsum.photos/id/237/200/300
//https://tse3.mm.bing.net/th?id=OIP.W7cIPvuoE22Xn7r4wHQ9ggHaJ4&pid=Api
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TextField(
            controller: imageTEC,
          ),
          TextButton(
            onPressed: addImage,
            child: const Text("Add Image"),
          ),
          Column(
            children: [
              Image.network(
                  "https://cao-prototype-bucket1.s3.ca-central-1.amazonaws.com/experimentation/Breakfast.jpg")
            ],
          ),
        ],
      ),
    );
  }
}
