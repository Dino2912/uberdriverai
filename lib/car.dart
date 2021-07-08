import 'package:flutter/material.dart';

class UberCar extends StatelessWidget {
  final carWidth;
  final carHeight;
  UberCar({Key? key, double this.carWidth = 100.0, double this.carHeight = 100.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (Image.asset(
      
      'lib/images/car.png',
      fit: BoxFit.fill,
      width: carWidth,
      height: carHeight,
    ));
  }
}
