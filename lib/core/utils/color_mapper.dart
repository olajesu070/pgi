import 'package:flutter/material.dart';

Map<int, Color> categoryColors = {
  1: const Color(0xFF87FD99),  // Entrances & Parking
  2: const Color(0xFFFF7043),  // PGI Display
  3: const Color(0xFFDFFF00),  // PGI Events
  4: const Color(0xFF26B300),  // Offices / HQs
  5: const Color(0xFF6BC2FF),  // Registration / Camping
  6: const Color(0xFFFF00F0),  // Seminars / Workshops
  7: const Color(0xFF00FFF7),  // Lines & Manufacturing
  8: const Color(0xFFFFC100),  // Sales & Food
  9: const Color(0xFFB9B9B9),  // PGI Bus Stops
  10: const Color(0xFFFF0000), // OFF-LIMITS
};

Color getColorForCategory(int categoryId) {
  return categoryColors[categoryId] ?? Colors.black; // Default color if none found
}
