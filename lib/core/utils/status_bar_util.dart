import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarUtil {
  static void setLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,  // Custom color
        statusBarIconBrightness: Brightness.light, // Light icons
        statusBarBrightness: Brightness.dark,  // iOS compatibility
      ),
    );
  }
}
