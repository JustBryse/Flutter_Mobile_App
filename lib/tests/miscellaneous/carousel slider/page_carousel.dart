import 'package:cao_prototype/support/utility.dart';
import 'package:cao_prototype/tests/miscellaneous/carousel%20slider/carousel_page1.dart';
import 'package:cao_prototype/tests/miscellaneous/carousel%20slider/carousel_page2.dart';
import 'package:cao_prototype/tests/miscellaneous/carousel%20slider/carousel_page3.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselSliderTestPage extends StatefulWidget {
  const CarouselSliderTestPage({super.key});

  @override
  State<CarouselSliderTestPage> createState() => _CarouselSliderTestPageState();
}

class _CarouselSliderTestPageState extends State<CarouselSliderTestPage> {
  PageController pc = PageController(initialPage: 0);

  @override
  void initState() {
    print("init page carousel main");
  }

  void navigateToTestPage1() {
    pc.jumpToPage(0);
  }

  void navigateToTestPage2() {
    pc.jumpToPage(1);
  }

  void navigateToTestPage3() {
    pc.jumpToPage(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Carousel Slider Test Page",
          style: TextStyle(
            color: Utility.secondaryColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          PageView(
            controller: pc,
            children: const [
              CarouselTestPage1(),
              CarouselTestPage2(),
              CarouselTestPage3(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: navigateToTestPage1,
                  child: const Text(
                    "Page 1",
                    style: TextStyle(
                      color: Utility.secondaryColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: navigateToTestPage2,
                  child: const Text(
                    "Page 2",
                    style: TextStyle(
                      color: Utility.secondaryColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: navigateToTestPage3,
                  child: const Text(
                    "Page 3",
                    style: TextStyle(
                      color: Utility.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
