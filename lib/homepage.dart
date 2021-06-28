import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uberdriverai/car.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double carX = 0;
  double carY = 0;
  bool gameStarted = false;
  bool carDrivingForward = false;
  bool carDrivingBackwards = false;
  bool carTurningLeft = false;
  bool carTurningRight = false;

  void startGame() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (carDrivingForward == true) {
        setState(() {
          carX += 0.01;
        });
      }
      if(carDrivingBackwards == true){
        setState(() {
          carX -= 0.01;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 0),
          alignment: Alignment(carX, carY),
          child: FloatingActionButton(
            onPressed: () {
              carDrivingBackwards == false
                ? carDrivingBackwards = true
                : carDrivingBackwards = false;
              gameStarted == false ? startGame() : null;
            },
            child: UberCar(),
          ),
        ),
      ],
    );
  }
}
