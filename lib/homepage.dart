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
    setState(() {
      gameStarted = true;
    });
    Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (carDrivingForward == true) {
        setState(() {
          carX += 0.01;
        });
      }
      if (carDrivingBackwards == true) {
        setState(() {
          carX -= 0.01;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 0),
            alignment: Alignment(carX, carY),
            child: UberCar(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              //width: 100,
              //height: 150,
              color: Colors.red,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Icon(Icons.keyboard_arrow_up),
                    onTapDown: (e) {
                      carDrivingForward = true;
                    },
                    onTapUp: (e) {
                      carDrivingForward = false;
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            carTurningLeft == false
                                ? carTurningLeft = true
                                : carTurningLeft = false;
                            // ignore: unnecessary_statements
                            gameStarted == false ? startGame() : null;
                          },
                          icon: Icon(Icons.keyboard_arrow_left)),
                      IconButton(
                          onPressed: () {
                            carTurningRight == false
                                ? carTurningRight = true
                                : carTurningRight = false;
                            // ignore: unnecessary_statements
                            gameStarted == false ? startGame() : null;
                          },
                          icon: Icon(Icons.keyboard_arrow_right)),
                    ],
                  ),
                  GestureDetector(
                    child: Icon(Icons.keyboard_arrow_down),
                    onTapDown: (e) {
                      carDrivingBackwards = true;
                    },
                    onTapUp: (e) {
                      carDrivingBackwards = false;
                    },
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: gameStarted == true ? false : true,
            child: Center(
              child: Container(
                color: Colors.purple,
                child: TextButton(
                  onPressed: startGame,
                  child: Text("START GAME",style: TextStyle(fontSize: 80,color: Colors.green),),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
