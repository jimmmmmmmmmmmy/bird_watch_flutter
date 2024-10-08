import 'dart:io';
import 'package:flutter/material.dart';
import '../gallery_page.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback onCapture;
  final List<String> photos;
  final double rotation;

  const CameraControls({
    Key? key,
    required this.onCapture,
    required this.photos,
    required this.rotation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _rotatedIcon(_buildGalleryButton(context)),
            _buildCaptureButton(),
            SizedBox(width: 60, height: 60), // Placeholder for symmetry
          ],
        ),
      ),
    );
  }

  Widget _rotatedIcon(Widget icon) {
    return Transform.rotate(
      angle: rotation,
      child: icon,
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
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
      onTap: onCapture,
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
}