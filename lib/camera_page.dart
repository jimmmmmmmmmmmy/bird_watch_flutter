import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'gallery_page.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  List<String> photos = [];
  FlashMode _currentFlashMode = FlashMode.off;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _lockOrientation();
    _initializeSensor();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _lockOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void _initializeSensor() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      double x = event.x;
      double y = event.y;
      
      // Map accelerometer values to rotation angles
      double newRotation = 0;
      if (y.abs() > x.abs()) {
        newRotation = y > 0 ? 0 : pi;
      } else {
        newRotation = x > 0 ? -pi / 2 : pi / 2;
      }
      
      if ((newRotation - _rotation).abs() > 0.1) {
        setState(() {
          _rotation = -newRotation;
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      print('No cameras available');
      return;
    }

    final CameraController cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = cameraController;

    try {
      await cameraController.initialize();
      await cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _takePicture() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return;
    }

    try {
      final XFile file = await cameraController.takePicture();
      
      // Get the current orientation
      final deviceOrientation = MediaQuery.of(context).orientation;
      
      // Process the image to correct orientation if needed
      final processedImage = await _processImage(file.path, deviceOrientation);
      
      setState(() {
        photos.insert(0, processedImage);
      });
    } on CameraException catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<String> _processImage(String imagePath, Orientation orientation) async {
    // You may need to use a package like image to rotate the image if necessary
    // For now, we'll just return the original path
    return imagePath;
  }

  Widget _buildFlashModeButton() {
    IconData icon;
    switch (_currentFlashMode) {
      case FlashMode.off:
        icon = Icons.flash_off;
        break;
      case FlashMode.auto:
        icon = Icons.flash_auto;
        break;
      case FlashMode.always:
        icon = Icons.flash_on;
        break;
      case FlashMode.torch:
        icon = Icons.highlight;
        break;
    }

    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 28),
      onPressed: () {
        setState(() {
          switch (_currentFlashMode) {
            case FlashMode.off:
              _currentFlashMode = FlashMode.auto;
              break;
            case FlashMode.auto:
              _currentFlashMode = FlashMode.always;
              break;
            case FlashMode.always:
              _currentFlashMode = FlashMode.torch;
              break;
            case FlashMode.torch:
              _currentFlashMode = FlashMode.off;
              break;
          }
        });
        _controller?.setFlashMode(_currentFlashMode);
      },
    );
  }

  Widget _rotatedIcon(Widget icon) {
    return Transform.rotate(
      angle: _rotation,
      child: icon,
    );
  }

  Widget _buildCameraPreview() {
    final size = MediaQuery.of(context).size;
    final previewSize = _controller!.value.previewSize!;
    final previewAspectRatio = previewSize.aspectRatio;
    final screenAspectRatio = size.aspectRatio;

    double scale;
    if (screenAspectRatio > previewAspectRatio) {
      scale = size.width / previewSize.width;
    } else {
      scale = size.height / previewSize.height;
    }

    scale = scale * 3;

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.scale(
          scale: scale,
          child: Center(
            child: CameraPreview(_controller!),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: _rotatedIcon(_buildFlashModeButton()),
        ),
        _buildCameraControls(),
      ],
    );
  }

  Widget _buildCameraControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _rotatedIcon(_buildGalleryButton()),
            _buildCaptureButton(),
            SizedBox(width: 60, height: 60), // Placeholder for symmetry
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryPage(photos: photos),
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: photos.isNotEmpty
            ? ClipOval(
                child: Image.file(
                  File(photos.first),
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.photo_library, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildCameraPreview(),
      ),
    );
  }
}