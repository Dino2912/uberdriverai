import 'dart:io';

import 'package:flutter/material.dart';

import 'drawmap.dart';

void main() {
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MapCreatorWidget());
    //return Stack(children: [DrawMapFromFile(mapName: "testmap")],);
  }
}

class MapCreatorWidget extends StatefulWidget {
  const MapCreatorWidget({Key? key}) : super(key: key);

  @override
  _MapCreatorWidgetState createState() => _MapCreatorWidgetState();
}

class _MapCreatorWidgetState extends State<MapCreatorWidget> {
  final mapName = "testmap";
  bool editing = false;
  dynamic firstPosX = 0.0;
  dynamic firstPosY = 0.0;
  bool firstPos = false;
  var markAreaSelected; //0=Spawn 1=Pickup 2=Dropoff

  _pentaCords(v) {
    v = v.toInt();
    v = v.toString();
    while (v.length < 5) {
      v = "0$v";
    }
    return v;
  }

  _readFile() {
    var fileName = 'lib/maps/$mapName.txt';
    var data = File(fileName).readAsStringSync();
    return data;
  }

  _handleOnTap(TapUpDetails details) {
    if (editing == true) {
      double? x = details.globalPosition.dx;
      double? y = details.globalPosition.dy;
      if (markAreaSelected == 0) {
        String result = _readFile();
        String sx = _pentaCords(x);
        String sy = _pentaCords(y);
        result = '$sx$sy${result.substring(10)}';
        var fileName = 'lib/maps/$mapName.txt';
        File(fileName).writeAsStringSync(result);
      } else {
        if (firstPosX == 0.0) {
          firstPosX = x;
          firstPosY = y;
          firstPos = true;
        } else {
          var result = _readFile();
          firstPosX = _pentaCords(firstPosX);
          firstPosY = _pentaCords(firstPosY);
          String sx = _pentaCords(x).toString();
          String sy = _pentaCords(y).toString();
          var data = '$result\n$firstPosX$firstPosY$sx$sy';
          var fileName = 'lib/maps/$mapName.txt';
          File(fileName).writeAsStringSync(data);
          firstPosX = 0.0;
          firstPosY = 0.0;
          //x = null;
          //y = null;
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        _handleOnTap(details);
      },
      child: Scaffold(
        body: Stack(
          children: [
            DrawMapFromFile(mapName: mapName),
            Positioned(
              left: 1400,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      markAreaSelected == null
                          ? markAreaSelected = 0
                          : markAreaSelected = null;
                    }),
                    icon: Icon(Icons.car_rental),
                    color: markAreaSelected == 0 ? Colors.green : Colors.black,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment(0, -1),
              child: Text(
                "First click has to be top left, second bottom right!",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  editing == false ? editing = true : editing = false;
                });
              },
              child: Text(
                "Edit",
                style: TextStyle(
                    color: editing == false ? Colors.red : Colors.green),
              ),
            ),
            Visibility(
              visible: editing,
              child: Align(
                alignment: Alignment(1, -1),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      var fileName = 'lib/maps/$mapName.txt';
                      File(fileName).writeAsStringSync("0010000100");
                    });
                  },
                  child: Text(
                    "Clear all",
                    style: TextStyle(color: Colors.yellow),
                  ),
                ),
              ),
            ),
            Visibility(
                child: Positioned(
                    top: firstPosY - 15.0,
                    left: firstPosX - 15.0,
                    child: Container(
                      width: 30,
                      height: 30,
                      child: Image.asset("lib/images/crosshair.png"),
                    ))),
          ],
        ),
      ),
    );
  }
}
