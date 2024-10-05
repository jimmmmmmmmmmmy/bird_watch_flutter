// services.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  // Initialize the camera
  Future<void> initializeCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      _isCameraInitialized = true;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
  }

  // Dispose the camera controller
  void disposeCamera() {
    _controller?.dispose();
  }

  // Check if the camera is initialized
  bool get isCameraInitialized => _isCameraInitialized;

  // Take a picture and return the file path
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }

    try {
      return await _controller!.takePicture();
    } on CameraException catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  // Process the image (e.g., rotate based on orientation)
  Future<String> processImage(String imagePath, Orientation orientation) async {
    // Implement image processing logic here if needed
    return imagePath; // For now, return the original path
  }

  // Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null) {
      await _controller!.setFlashMode(mode);
    }
  }

  // Get the camera controller
  CameraController? get controller => _controller;
}