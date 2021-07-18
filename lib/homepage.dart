import 'dart:async';
import 'dart:io';
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
  final mapName = "testmap";
  final carSpeed = 5;

  double screenWidth = WidgetsBinding.instance!.window.physicalSize.width;
  double screenHeight = WidgetsBinding.instance!.window.physicalSize.height;
  double carX = 100.0;
  double carY = 100.0;
  int carDirection = 0;
  bool gameStarted = false;
  bool carDrivingForward = false;
  bool carDrivingBackwards = false;
  bool carTurningLeft = false;
  bool carTurningRight = false;
  double carWidth = 50;
  double carHeight = 50;
  bool customerPickedUp = false;
  int markedAreaPoints = 0;
  var stopWatchTimer = ValueNotifier(0);
  bool gameEnded = false;

  List<String> lines = [];
  List<String> markedAreas = [];

  List<LogicalKeyboardKey> heldKeys = [];

  void crashCrashed() {
    debugPrint("The car has crashed!");
  }

  isCollidingWithCar(fx, fy, sx, sy) {
    if (carX > fx && carY > fy) {
      if (carX < sx && carY < sy) {
        return true;
      }
    }
    if (carX + carWidth > fx && carY > fy) {
      if (carX + carWidth < sx && carY < sy) {
        return true;
      }
    }
    if (carX > fx && carY + carHeight > fy) {
      if (carX < sx && carY + carHeight < sy) {
        return true;
      }
    }
    if (carX + carWidth > fx && carY + carHeight > fy) {
      if (carX + carWidth < sx && carY + carHeight < sy) {
        return true;
      }
    }
    return false;
  }

  void startGame() {
    var fileName = 'lib/maps/$mapName.txt';
    lines = File(fileName).readAsLinesSync();
    carX = double.parse(lines[0].substring(0, 5));
    carY = double.parse(lines[0].substring(5, 10));
    setState(() {
      gameStarted = true;
    });
    Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (carDrivingForward == true) {
        setState(() {
          carX += cos(carDirection * pi / 180) * carSpeed;
          carY += sin(carDirection * pi / 180) * carSpeed;
        });
      }
      if (carDrivingBackwards == true) {
        setState(() {
          carX -= cos(carDirection * pi / 180) * carSpeed;
          carY -= sin(carDirection * pi / 180) * carSpeed;
        });
      }
      if (carTurningLeft == true) {
        if (carDrivingForward && !carDrivingBackwards) {
          setState(() {
            carDirection -= 3;
          });
        } else if (carDrivingBackwards && !carDrivingForward) {
          setState(() {
            carDirection += 3;
          });
        }
      }
      if (carTurningRight == true) {
        if (carDrivingForward && !carDrivingBackwards) {
          setState(() {
            carDirection += 3;
          });
        } else if (carDrivingBackwards && !carDrivingForward) {
          setState(() {
            carDirection -= 3;
          });
        }
      }
    });
    for (var i = 0; i < 3; i++) {
      markedAreas.add(lines[0]);
      lines.removeAt(0);
      debugPrint("Removed");
    }
    debugPrint(lines.length.toString());
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      debugPrint("X:$carX | Y:$carY");
      for (var v in lines) {
        bool isCollidingWithCarBool = isCollidingWithCar(
            double.parse(v.substring(0, 5)),
            double.parse(v.substring(5, 10)),
            double.parse(v.substring(10, 15)),
            double.parse(v.substring(15, 20)));
        if (isCollidingWithCarBool == true) {
          crashCrashed();
        }
      }
      bool isInMarkedArea = customerPickedUp == false
          ? isCollidingWithCar(
              double.parse(markedAreas[1].substring(0, 5)),
              double.parse(markedAreas[1].substring(5, 10)),
              double.parse(markedAreas[1].substring(10, 15)),
              double.parse(markedAreas[1].substring(15, 20)))
          : isCollidingWithCar(
              double.parse(markedAreas[2].substring(0, 5)),
              double.parse(markedAreas[2].substring(5, 10)),
              double.parse(markedAreas[2].substring(10, 15)),
              double.parse(markedAreas[2].substring(15, 20)));
      isInMarkedArea ? markedAreaPoints++ : markedAreaPoints = 0;
      // ignore: unnecessary_statements
      markedAreaPoints >= 20
          ? customerPickedUp
              ? gameEnded = true
              : setState(() {
                  customerPickedUp = true;
                })
          // ignore: unnecessary_statements
          : null;
    });
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      // ignore: unnecessary_statements
      !gameEnded ? stopWatchTimer.value++ : null;
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
            gameStarted
                ? Stack(
                    children: [
                      Positioned(
                        //Pickup spot
                        left: double.parse(markedAreas[1].substring(0, 5)),
                        top: double.parse(markedAreas[1].substring(5, 10)),
                        child: Opacity(
                          opacity: customerPickedUp == false ? 0.7 : 0,
                          child: Container(
                            color: Colors.yellow,
                            width: double.parse(
                                    markedAreas[1].substring(10, 15)) -
                                double.parse(markedAreas[1].substring(0, 5)),
                            height: double.parse(
                                    markedAreas[1].substring(15, 20)) -
                                double.parse(markedAreas[1].substring(5, 10)),
                          ),
                        ),
                      ),
                      Positioned(
                        //Drop off
                        left: double.parse(markedAreas[2].substring(0, 5)),
                        top: double.parse(markedAreas[2].substring(5, 10)),
                        child: Opacity(
                          opacity: customerPickedUp == true ? 0.7 : 0,
                          child: Container(
                            color: Colors.yellow,
                            width: double.parse(
                                    markedAreas[2].substring(10, 15)) -
                                double.parse(markedAreas[2].substring(0, 5)),
                            height: double.parse(
                                    markedAreas[2].substring(15, 20)) -
                                double.parse(markedAreas[2].substring(5, 10)),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Stack(
              children: [
                for (var i in lines)
                  Positioned(
                      left: double.parse(i.substring(0, 5)),
                      top: double.parse(i.substring(5, 10)),
                      child: Container(
                        color: Colors.black,
                        width: double.parse(i.substring(10, 15)) -
                            double.parse(i.substring(0, 5)),
                        height: double.parse(i.substring(15, 20)) -
                            double.parse(i.substring(5, 10)),
                      ))
              ],
            ),
            Positioned(
              top: carY,
              left: carX,
              child: Container(
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(carDirection / 360),
                  child: UberCar(
                    carWidth: carWidth,
                    carHeight: carHeight,
                  ),
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
            Positioned(
                left: 1200,
                child: ValueListenableBuilder(
                  valueListenable: stopWatchTimer,
                  builder: (context, int n, c) {
                    double t = n / 100;
                    return Text('$t');
                  },
                )),
          ],
        ),
      ),
    );
  }
}
