import 'package:flutter/material.dart';
import 'package:medicine_try1/ui_colors/green.dart';

Widget titlePosition({
  required String title,
}) {
  return Positioned(
    top: -5.0,
    left: 10.0,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: greencolor, width: 2)),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12.0),
      ),
    ),
  );
}

Widget titlePositionS({
  required String titleS,
}) {
  return Positioned(
    top: -10.0,
    left: 10.0,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: greencolor, width: 2)),
      child: Text(
        titleS,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12.0),
      ),
    ),
  );
}
