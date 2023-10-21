import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class CarouselTestPage1 extends StatefulWidget {
  const CarouselTestPage1({super.key});

  @override
  State<CarouselTestPage1> createState() => _CarouselTestPage1State();
}

class _CarouselTestPage1State extends State<CarouselTestPage1> {
  @override
  void initState() {
    print("init test page 1");
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Align(
        alignment: Alignment.center,
        child: Text(
          "Carousel Slider Test Page 1",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      ),
    );
  }
}
