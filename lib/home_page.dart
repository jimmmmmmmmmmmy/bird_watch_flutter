import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_page.dart';

class HomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomePage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CameraPage(cameras: cameras),
    );
  }
}