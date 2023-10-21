import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class CarouselTestPage3 extends StatefulWidget {
  const CarouselTestPage3({super.key});

  @override
  State<CarouselTestPage3> createState() => _CarouselTestPage3State();
}

class _CarouselTestPage3State extends State<CarouselTestPage3> {
  @override
  void initState() {
    print("init test page 3");
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Align(
        alignment: Alignment.center,
        child: Text(
          "Carousel Slider Test Page 3",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      ),
    );
  }
}
