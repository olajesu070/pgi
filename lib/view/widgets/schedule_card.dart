import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final Map<String, String> event;

  const ScheduleCard(this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to event detail screen or handle tap
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                event['imageUrl']!,
                width: 80,
                height: 92,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Time
                  Text(
                    '${event['date']} at ${event['time']}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF0A5338) ),
                  ),
                  const SizedBox(height: 4),
                  // Event Title
                  Text(
                    event['title']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location with Icon
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        event['location']!,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
