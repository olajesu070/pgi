import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final String title;
  final Uint8List imageBytes;

  const ImageViewer({Key? key, required this.title, required this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Image.memory(imageBytes),
      ),
    );
  }
}
