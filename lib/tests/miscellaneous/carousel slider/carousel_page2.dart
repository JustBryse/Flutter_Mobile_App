import 'package:cao_prototype/support/utility.dart';
import 'package:flutter/material.dart';

class CarouselTestPage2 extends StatefulWidget {
  const CarouselTestPage2({super.key});

  @override
  State<CarouselTestPage2> createState() => _CarouselTestPage2State();
}

class _CarouselTestPage2State extends State<CarouselTestPage2> {
  @override
  void initState() {
    print("init test page 2");
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Align(
        alignment: Alignment.center,
        child: Text(
          "Carousel Slider Test Page 2",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      ),
    );
  }
}
