import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uberdriverai/car.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double screenWidth = WidgetsBinding.instance!.window.physicalSize.width;
  double screenHeight = WidgetsBinding.instance!.window.physicalSize.height;
  double carX = 0.2;
  double carY = 0.2;
  int carDirection = 0;
  bool gameStarted = false;
  bool carDrivingForward = false;
  bool carDrivingBackwards = false;
  bool carTurningLeft = false;
  bool carTurningRight = false;
  double carWidth = 100;
  double carHeight = 50;

  List<LogicalKeyboardKey> heldKeys = [];

  void startGame() {
    debugPrint(screenHeight.toString());
    setState(() {
      gameStarted = true;
    });
    Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (carDrivingForward == true) {
        setState(() {
          carX += 0.01 * cos(carDirection * pi / 180);
          carY += 0.01 * sin(carDirection * pi / 180);
        });
      }
      if (carDrivingBackwards == true) {
        setState(() {
          carX -= 0.01;
        });
      }
      if (carTurningLeft == true) {
        setState(() {
          carDirection -= 3;
        });
      }
      if (carTurningRight == true) {
        setState(() {
          carDirection += 3;
        });
      }
    });
  }

  void makeCarDriveForward(v) {
    carDrivingForward = v;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (e) {
          final key = e.logicalKey;
          if (e is RawKeyDownEvent) {
            //debugPrint(key);
            if (heldKeys.contains(key)) return;
            heldKeys.add(key);
            if (e.isKeyPressed(LogicalKeyboardKey.keyW)) {
              carDrivingForward = true;
            }
            if (e.isKeyPressed(LogicalKeyboardKey.keyS)) {
              carDrivingBackwards = true;
            }
            if (e.isKeyPressed(LogicalKeyboardKey.keyA)) {
              carTurningLeft = true;
            }
            if (e.isKeyPressed(LogicalKeyboardKey.keyD)) {
              carTurningRight = true;
            }
          } else {
            heldKeys.remove(key);
            if (key == LogicalKeyboardKey.keyW) {
              carDrivingForward = false;
            }
            if (key == LogicalKeyboardKey.keyS) {
              carDrivingBackwards = false;
            }
            if (key == LogicalKeyboardKey.keyA) {
              carTurningLeft = false;
            }
            if (key == LogicalKeyboardKey.keyD) {
              carTurningRight = false;
            }
          }
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 0),
              alignment: Alignment(carX + ((carWidth / screenWidth) / 2),
                  carY + ((carHeight / screenHeight) / 2)),
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(carDirection / 360),
                child: UberCar(
                  carWidth: carWidth,
                  carHeight: carHeight,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 50,
                height: 72,
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
                        GestureDetector(
                          child: Icon(Icons.keyboard_arrow_left),
                          onTapDown: (e) {
                            carTurningLeft = true;
                          },
                          onTapUp: (e) {
                            carTurningLeft = false;
                          },
                        ),
                        GestureDetector(
                          child: Icon(Icons.keyboard_arrow_right),
                          onTapDown: (e) {
                            carTurningRight = true;
                          },
                          onTapUp: (e) {
                            carTurningRight = false;
                          },
                        ),
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
                    child: Text(
                      "START GAME",
                      style: TextStyle(fontSize: 80, color: Colors.green),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
