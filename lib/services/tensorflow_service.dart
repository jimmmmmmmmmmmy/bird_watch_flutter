import 'dart:io';
import 'dart:math' show exp;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:collection';

class TensorFlowService {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilenet_v3_large.tflite');
      _labels = await _loadLabels('assets/labels.txt');
      print('Model and labels loaded successfully');
      print('Model loaded. Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Model loaded. Output shape: ${_interpreter!.getOutputTensor(0).shape}');
      _isModelLoaded = true;
    } on FileSystemException catch (e) {
      print('Failed to load model file: $e');
    } on Exception catch (e) {
      print('Failed to load labels: $e');
    }
  }

  Future<List<String>> _loadLabels(String labelsFileName) async {
    return await rootBundle.loadString(labelsFileName)
        .then((str) => str.split('\n'));
  }

  Future<List<Recognition>> runInference(CameraImage cameraImage) async {
  if (!_isModelLoaded || _interpreter == null || _labels == null) return [];

  try {
    final input = _preprocessCameraImage(cameraImage);
    
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    
    print("Input shape from model: $inputShape");
    print("Output shape from model: $outputShape");
    
    // Reshape input to 4D [1, 224, 224, 3]
    final reshapedInput = input.reshape([1, 224, 224, 3]);
    final output = [List<double>.filled(outputShape[1], 0.0)];

    print("Reshaped input shape: ${reshapedInput.shape}");
    print("Prepared output shape: ${output[0].length}");

    _interpreter!.run(reshapedInput, output);

    final results = output[0];
    final processedResults = softmax(results);
    final recognitions = <Recognition>[];

    for (var i = 0; i < processedResults.length && i < _labels!.length; i++) {
      recognitions.add(Recognition(i, _labels![i], processedResults[i]));
    }

    recognitions.sort((a, b) => b.score.compareTo(a.score));
    return recognitions.take(5).toList();
  } catch (e, stackTrace) {
    print('Error running model inference: $e');
    print('Stack trace: $stackTrace');
    return [];
  }
}

  Float32List _preprocessCameraImage(CameraImage cameraImage) {
  print("Camera image format: ${cameraImage.format.group}");
  print("Number of planes: ${cameraImage.planes.length}");
  print("Input shape: ${cameraImage.width}x${cameraImage.height}");
  print("Plane 0 bytes: ${cameraImage.planes[0].bytes.length}");

  if (cameraImage.format.group != ImageFormatGroup.bgra8888) {
    throw Exception('Unsupported image format: ${cameraImage.format.group}');
  }

  final img.Image image = img.Image.fromBytes(
    width: cameraImage.width,
    height: cameraImage.height,
    bytes: cameraImage.planes[0].bytes.buffer,
    order: img.ChannelOrder.bgra,
  );

  final resizedImage = img.copyResize(image, width: 224, height: 224);

  final inputBuffer = Float32List(224 * 224 * 3);
  int pixelIndex = 0;
  for (var y = 0; y < 224; y++) {
    for (var x = 0; x < 224; x++) {
      final pixel = resizedImage.getPixel(x, y);
      inputBuffer[pixelIndex++] = pixel.r.toDouble() / 255.0; // Red
      inputBuffer[pixelIndex++] = pixel.g.toDouble() / 255.0; // Green
      inputBuffer[pixelIndex++] = pixel.b.toDouble() / 255.0; // Blue
    }
  }

  return inputBuffer;
}


  List<double> softmax(List<double> input) {
    double sum = input.fold(0.0, (prev, curr) => prev + exp(curr));
    return input.map((x) => exp(x) / sum).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}

class Recognition {
  final int id;
  final String label;
  final double score;

  Recognition(this.id, this.label, this.score);
}