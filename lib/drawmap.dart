import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uberdriverai/car.dart';

class DrawMapFromFile extends StatelessWidget {
  final mapName;
  DrawMapFromFile({Key? key, required this.mapName}) : super(key: key);

  readFromFile() {
    var fileName = 'lib/maps/$mapName.txt';
    var lines = File(fileName).readAsLinesSync();
    var markedAreas = [];
    int loops;
    lines.length > 3 ? loops = 3 : loops = lines.length;
    for (var i = 0; i < loops; i++) {
      markedAreas.add(lines[0]);
      lines.removeAt(0);
    }
    if (lines.length < 1) {
      lines.add("00000000000000000000");
    }
    return Stack(
      children: [
        Positioned(
          top: double.parse(markedAreas[0].substring(5, 10)),
          left: double.parse(markedAreas[0].substring(0, 5)),
          child: UberCar(
            carWidth: 50,
            carHeight: 50,
          ),
        ),
        markedAreas.length > 1
            ? Positioned(
                left: double.parse(markedAreas[1].substring(0, 5)),
                top: double.parse(markedAreas[1].substring(5, 10)),
                child: Container(
                  color: Colors.green,
                  width: double.parse(markedAreas[1].substring(10, 15)) -
                      double.parse(markedAreas[1].substring(0, 5)),
                  height: double.parse(markedAreas[1].substring(15, 20)) -
                      double.parse(markedAreas[1].substring(5, 10)),
                ))
            : Container(),
        markedAreas.length > 2
            ? Positioned(
                left: double.parse(markedAreas[2].substring(0, 5)),
                top: double.parse(markedAreas[2].substring(5, 10)),
                child: Container(
                  color: Colors.yellow,
                  width: double.parse(markedAreas[2].substring(10, 15)) -
                      double.parse(markedAreas[2].substring(0, 5)),
                  height: double.parse(markedAreas[2].substring(15, 20)) -
                      double.parse(markedAreas[2].substring(5, 10)),
                ))
            : Container(),
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
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return readFromFile();
  }
}
