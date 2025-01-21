
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';

class ImageViewer extends StatefulWidget {
  final String title;
  final Uint8List imageBytes;

  const ImageViewer({super.key, required this.title, required this.imageBytes});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {

   @override
  void initState() {
    super.initState();
     _setStatusBarStyle();
  }

  
 void _setStatusBarStyle() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,  // Transparent status bar
      statusBarIconBrightness: Brightness.light,  // Light icons for dark backgrounds
      statusBarBrightness: Brightness.dark,  // Adjust for iOS
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
        children: [
           CustomAppBarBody(
            title: widget.title,
          ),
          Expanded(
            child:  Center(
            child: Image.memory(widget.imageBytes),
          ),
            )
         
        ],
      )
      ),
    );
  }
}
