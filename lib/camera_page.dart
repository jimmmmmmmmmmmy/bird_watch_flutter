import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'services/camera_service.dart';
import 'services/tensorflow_service.dart';
import 'widgets/camera_controls.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraService _cameraService;
  late TensorFlowService _tensorFlowService;
  bool _isCameraInitialized = false;
  List<String> photos = [];
  FlashMode _currentFlashMode = FlashMode.off;
  double _rotation = 0;
  List<Recognition> _recognitions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraService = CameraService();
    _tensorFlowService = TensorFlowService();
    _initializeCamera();
    _lockOrientation();
    _initializeSensor();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.disposeCamera();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      print('No cameras available');
      return;
    }

    try {
      print('Initializing camera...');
      await _cameraService.initializeCamera(widget.cameras[0]);
      await _tensorFlowService.loadModel();
      _cameraService.controller?.startImageStream(_processCameraImage);
      print('Camera initialized: ${_cameraService.isCameraInitialized}');
      if (mounted) {
        setState(() {
          _isCameraInitialized = _cameraService.isCameraInitialized;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _processCameraImage(CameraImage image) async {
    final recognitions = await _tensorFlowService.runInference(image);
    if (mounted) {
      setState(() {
        _recognitions = recognitions;
      });
    }
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('App lifecycle state changed to: $state');
    if (state == AppLifecycleState.inactive) {
      _cameraService.disposeCamera();
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  Future<void> _takePicture() async {
    final file = await _cameraService.takePicture();
    if (file != null) {
      final deviceOrientation = MediaQuery.of(context).orientation;
      final processedImage = await _processImageFile(file.path, deviceOrientation);
    
      setState(() {
        photos.insert(0, processedImage);
      });
    }
  }
  
  Future<String> _processImageFile(String imagePath, Orientation orientation) async {
    // Implement image processing logic here if needed
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
        _cameraService.setFlashMode(_currentFlashMode);
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
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final size = MediaQuery.of(context).size;
    final previewSize = controller.value.previewSize!;
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
            child: CameraPreview(controller),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: _rotatedIcon(_buildFlashModeButton()),
        ),
        CameraControls(
          onCapture: _takePicture,
          photos: photos,
          rotation: _rotation,
        ),
        Positioned(
          bottom: 100,
          left: 10,
          right: 10,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              itemCount: _recognitions.length,
              itemBuilder: (context, index) {
                final recognition = _recognitions[index];
                return ListTile(
                  title: Text(
                    recognition.label,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Confidence: ${(recognition.score * 100).toStringAsFixed(2)}%',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building CameraPage. Camera initialized: $_isCameraInitialized');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isCameraInitialized
            ? _buildCameraPreview()
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
