import 'dart:io';
import 'package:flutter/material.dart';
import 'full_screen_image.dart';

class GalleryPage extends StatelessWidget {
  final List<String> photos;

  const GalleryPage({Key? key, required this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Gallery', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImagePage(imagePath: photos[index]),
                ),
              );
            },
            child: Image.file(
              File(photos[index]),
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}