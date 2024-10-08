import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class CameraService {
  CameraController? _controller;
  bool _isCameraInitialized = false;

  Future<void> initializeCamera(CameraDescription camera) async {
    print('CameraService: Initializing camera...');
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      _isCameraInitialized = true;
      print('CameraService: Camera initialized successfully');
    } on CameraException catch (e) {
      print('CameraService: Error initializing camera: $e');
      _isCameraInitialized = false;
    }
  }

  Future<void> disposeCamera() async {
    print('CameraService: Disposing camera...');
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
      _isCameraInitialized = false;
    }
    print('CameraService: Camera disposed');
  }

  bool get isCameraInitialized => _isCameraInitialized;

  Future<XFile?> takePicture() async {
    if (_controller == null || !_isCameraInitialized) {
      print('Error: Camera is not initialized.');
      return null;
    }

    try {
      return await _controller!.takePicture();
    } on CameraException catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null && _isCameraInitialized) {
      try {
        await _controller!.setFlashMode(mode);
      } on CameraException catch (e) {
        print('Error setting flash mode: $e');
      }
    }
  }

  CameraController? get controller => _controller;
}