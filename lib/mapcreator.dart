import 'dart:io';

import 'package:flutter/material.dart';

import 'drawmap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  bool editing = false;

  @override
  Widget build(BuildContext context) {
    return MapCreatorWidget();
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
  var firstPosX;
  var firstPosY;

  _readFile(x, y) {
    var fileName = 'lib/maps/$mapName.txt';
    var data = File(fileName).readAsString();
    data = '$data\n$firstPosX$firstPosY$x$y' as Future<String>;
    return data;
  }

  _handleOnTap(TapUpDetails details) {
    debugPrint("Something wokring atleast");
    if (editing == true) {
      debugPrint("Is true");
      var x = details.globalPosition.dx;
      var y = details.globalPosition.dy;
      if (firstPosX == null) {
        firstPosX = x;
        firstPosY = y;
      } else {
        _readFile(x, y).then((String result) {
          var fileName = 'lib/maps/$mapName.txt';
          File(fileName).writeAsString(result);
        });

        debugPrint("Added stuff lmao");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
          debugPrint("UP");
          _handleOnTap(details);
        },
      child: MaterialApp(
        home: Stack(
          children: [
            DrawMapFromFile(mapName: mapName),
            TextButton(
                onPressed: () {
                  setState(() {
                    editing == false ? editing = true : editing = false;
                  });
    
                  debugPrint(editing.toString());
                },
                child: Text(
                  "Edit",
                  style: TextStyle(
                      color: editing == false ? Colors.red : Colors.green),
                ))
          ],
        ),
      ),
    );
  }
}
