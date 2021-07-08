import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class DrawMapFromFile extends StatelessWidget {
  final mapName;
  DrawMapFromFile({Key? key, required this.mapName}) : super(key: key);




  readFromFile() {
    var fileName = 'lib/maps/$mapName.txt';
    var lines = File(fileName).readAsLinesSync();
    debugPrint(lines[0].substring(0,5));
    return Stack(children: [for(var i in lines) Positioned(left: double.parse(i.substring(0,5)),top: double.parse(i.substring(5,10)),child: Container(color: Colors.white,width: double.parse(i.substring(10,15))-double.parse(i.substring(0,5)), height: double.parse(i.substring(15,20))-double.parse(i.substring(5,10)),))],);
    //return Row(children: [for(var i in allParts) Container(color: Colors.red,width: 100, height: 100,)],);
  }

  @override
  Widget build(BuildContext context) {
    return readFromFile();
  }
}
