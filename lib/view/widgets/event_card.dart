import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String coverImageUrl;
  final String date;
  final String title;
  final List<String> attendeeAvatars;
  final int rsvpCount;
  final String location;

  const EventCard({
    super.key,
    required this.coverImageUrl,
    required this.date,
    required this.title,
    required this.attendeeAvatars,
    required this.rsvpCount,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Constrain the width of the card itself
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image with Date and Bookmark
            Stack(
              children: [
                // Constrain the cover image within the card width
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 150), // Set max height
                    child: Image.network(
                      coverImageUrl,
                      fit: BoxFit.cover,
                      width: 250, // Set a fixed width for the image to match card
                    ),
                  ),
                ),
                // Date Box
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      date,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Bookmark Icon
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      // Handle bookmark action
                    },
                    child: const Icon(
                      Icons.bookmark_border,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Attendee Avatars and RSVP Count
                  Row(
                    children: [
                      // Display the first few avatars
                      SizedBox(
                        height: 30,
                        child: Stack(
                          children: attendeeAvatars.asMap().entries.map((entry) {
                            int index = entry.key;
                            String avatarUrl = entry.value;

                            return Positioned(
                              left: index * 20.0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundImage: NetworkImage(avatarUrl),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('+$rsvpCount Going', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location Icon and Location Text
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
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
