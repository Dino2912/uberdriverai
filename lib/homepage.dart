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
  bool getDistances = true;

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

  double lineLabelWidth = 30;
  double lineLabelHeight = 20;
  var lineForward = ValueNotifier(0.0);
  var lineBackwards = ValueNotifier(0.0);
  var lineLeft = ValueNotifier(0.0);
  var lineRight = ValueNotifier(0.0);

  List<String> lines = [];
  List<String> markedAreas = [];

  List<LogicalKeyboardKey> heldKeys = [];

  void crashCrashed() {
    debugPrint("The car has crashed!");
  }

  isColliding(fx, fy, sx, sy, tx, ty, ex, ey) {
    if (tx > fx && ty > fy) {
      if (tx < sx && ty < sy) {
        return true;
      }
    }
    if (ex > fx && ty > fy) {
      if (ex < sx && ty < sy) {
        return true;
      }
    }
    if (tx > fx && ey > fy) {
      if (tx < sx && ey < sy) {
        return true;
      }
    }
    if (ex > fx && ey > fy) {
      if (ex < sx && ey < sy) {
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
      //debugPrint("X:$carX | Y:$carY");
      for (var v in lines) {
        bool isCollidingWithCarBool = isColliding(
            double.parse(v.substring(0, 5)),
            double.parse(v.substring(5, 10)),
            double.parse(v.substring(10, 15)),
            double.parse(v.substring(15, 20)),
            carX,
            carY,
            carX + carWidth,
            carY + carHeight);
        if (isCollidingWithCarBool == true) {
          crashCrashed();
        }
      }
      bool isInMarkedArea = customerPickedUp == false
          ? isColliding(
              double.parse(markedAreas[1].substring(0, 5)),
              double.parse(markedAreas[1].substring(5, 10)),
              double.parse(markedAreas[1].substring(10, 15)),
              double.parse(markedAreas[1].substring(15, 20)),
              carX,
              carY,
              carX + carWidth,
              carY + carHeight)
          : isColliding(
              double.parse(markedAreas[2].substring(0, 5)),
              double.parse(markedAreas[2].substring(5, 10)),
              double.parse(markedAreas[2].substring(10, 15)),
              double.parse(markedAreas[2].substring(15, 20)),
              carX,
              carY,
              carX + carWidth,
              carY + carHeight);
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
    getDistances
        ? Timer.periodic(Duration(milliseconds: 100), (timer) {
            double cpx = carX + (carWidth / 2);
            double cpy = carY;
            bool hitWall = false;
            while (!hitWall) {
              cpy--;
              for (var v in lines) {
                hitWall = isColliding(
                    double.parse(v.substring(0, 5)),
                    double.parse(v.substring(5, 10)),
                    double.parse(v.substring(10, 15)),
                    double.parse(v.substring(15, 20)),
                    cpx,
                    cpy,
                    cpx,
                    cpy);
                if (hitWall) {
                  break;
                }
              }
              if (hitWall) {
                break;
              }
              if (cpy <= 0.0) {
                break;
              }
            }
            lineForward.value = cpy;
            //debugPrint(lineForward.toString());
            cpy = carY + carHeight;
            hitWall = false;
            while (!hitWall) {
              cpy++;
              for (var v in lines) {
                hitWall = isColliding(
                    double.parse(v.substring(0, 5)),
                    double.parse(v.substring(5, 10)),
                    double.parse(v.substring(10, 15)),
                    double.parse(v.substring(15, 20)),
                    cpx,
                    cpy,
                    cpx,
                    cpy);
                if (hitWall) {
                  break;
                }
              }
              if (hitWall) {
                break;
              }
              if (cpy >= screenHeight) {
                break;
              }
            }
            lineBackwards.value = cpy;
            //
            cpx = carX;
            cpy = carY + (carHeight / 2);
            hitWall = false;
            while (!hitWall) {
              cpx--;
              for (var v in lines) {
                hitWall = isColliding(
                    double.parse(v.substring(0, 5)),
                    double.parse(v.substring(5, 10)),
                    double.parse(v.substring(10, 15)),
                    double.parse(v.substring(15, 20)),
                    cpx,
                    cpy,
                    cpx,
                    cpy);
                if (hitWall) {
                  break;
                }
              }
              if (hitWall) {
                break;
              }
              if (cpx <= 0.0) {
                break;
              }
            }
            lineLeft.value = cpx;
            //
            cpx = carX + carWidth;
            hitWall = false;
            while (!hitWall) {
              cpx++;
              for (var v in lines) {
                hitWall = isColliding(
                    double.parse(v.substring(0, 5)),
                    double.parse(v.substring(5, 10)),
                    double.parse(v.substring(10, 15)),
                    double.parse(v.substring(15, 20)),
                    cpx,
                    cpy,
                    cpx,
                    cpy);
                if (hitWall) {
                  break;
                }
              }
              if (hitWall) {
                break;
              }
              if (cpx >= screenWidth) {
                break;
              }
            }
            lineRight.value = cpx;
          })
        // ignore: unnecessary_statements
        : null;
    Timer.periodic(Duration(milliseconds: 100), (timer) {
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
                      getDistances
                          ? Stack(
                              children: [
                                Positioned(
                                  child: Container(
                                    child: ValueListenableBuilder(
                                      valueListenable: lineForward,
                                      builder: (context, double n, c) {
                                        int cn = carY.floor() - n.floor();
                                        String t = cn.toString();
                                        return Text(
                                          '$t',
                                          style: TextStyle(fontSize: 15),
                                        );
                                      },
                                    ),
                                    width: lineLabelWidth,
                                    height: lineLabelHeight,
                                  ),
                                  top: lineForward.value,
                                  left: carX +
                                      (carWidth / 2) -
                                      (lineLabelWidth / 2),
                                ),
                                Positioned(
                                  child: Container(
                                    child: ValueListenableBuilder(
                                      valueListenable: lineBackwards,
                                      builder: (context, double n, c) {
                                        int cn = n.floor() - carY.floor();
                                        String t = cn.toString();
                                        return Text(
                                          '$t',
                                          style: TextStyle(fontSize: 15),
                                        );
                                      },
                                    ),
                                    width: lineLabelWidth,
                                    height: lineLabelHeight,
                                  ),
                                  top: lineBackwards.value - lineLabelHeight,
                                  left: carX +
                                      (carWidth / 2) -
                                      (lineLabelWidth / 2),
                                ),
                                Positioned(
                                  child: Container(
                                    child: ValueListenableBuilder(
                                      valueListenable: lineLeft,
                                      builder: (context, double n, c) {
                                        int cn = carX.floor() - n.floor();
                                        String t = cn.toString();
                                        return Text(
                                          '$t',
                                          style: TextStyle(fontSize: 15),
                                        );
                                      },
                                    ),
                                    width: lineLabelWidth,
                                    height: lineLabelHeight,
                                  ),
                                  top: carY +
                                      (carHeight / 2) -
                                      (lineLabelHeight / 2),
                                  left: lineLeft.value,
                                ),
                                Positioned(
                                  child: Container(
                                    child: ValueListenableBuilder(
                                      valueListenable: lineRight,
                                      builder: (context, double n, c) {
                                        int cn = n.floor() - carX.floor();
                                        String t = cn.toString();
                                        return Text(
                                          '$t',
                                          style: TextStyle(fontSize: 15),
                                        );
                                      },
                                    ),
                                    width: lineLabelWidth,
                                    height: lineLabelHeight,
                                  ),
                                  top: carY +
                                      (carHeight / 2) -
                                      (lineLabelHeight / 2),
                                  left: lineRight.value - lineLabelWidth,
                                )
                              ],
                            )
                          : Container(),
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
