import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home_page.dart';

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera App',
      theme: ThemeData.dark(),
      home: HomePage(cameras: cameras),
    );
  }
}