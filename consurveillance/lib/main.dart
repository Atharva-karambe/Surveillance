import 'package:flutter/material.dart';
import 'package:consurveillance/page/location.dart';
import 'package:consurveillance/page/home.dart';
import 'package:consurveillance/page/test.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/location',
    routes: {
      '/location': (context) => Location(),
      '/home': (context) => Home(), 
      '/test': (context) => Test(), 
    },
    ));
}

