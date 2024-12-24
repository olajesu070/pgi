import 'package:flutter/material.dart';
import 'package:pgi/view/explore/event_detail_screen.dart';

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String date;
  final String title;
  final List<String> attendeeAvatars;
  final String location;
  final int goingCount;

  const EventCard({
    super.key,
    required this.imageUrl,
    required this.date,
    required this.title,
    required this.attendeeAvatars,
    required this.location,
    required this.goingCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(
              coverImageUrl: imageUrl,
              title: title,
              date: date,
              time: '4:00 pm to 9:00 pm', // Example time, customize as needed
              centerName: 'Gala Convention Centre', // Replace with actual data
              address: location,
              organizerName: 'John Doe', // Replace with actual data
              eventDetails: 'Celebrate Independence Day in historic St. Augustine with a spectacular display of fireworks over the scenic Matanzas Bay! Enjoy an evening filled with patriotic music, delicious food from local vendors. Read More...', // Replace as needed
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildImage(),
                _buildDateBox(),
              ],
            ),
            const SizedBox(height: 8),
            _buildEventDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 120,
        width: double.infinity,
      ),
    );
  }

  Widget _buildDateBox() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xB1FFFFFF),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          date,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.length > 20 ? '${title.substring(0, 20)}...' : title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildAttendeeRow(),
        const SizedBox(height: 8),
        _buildLocationRow(),
      ],
    );
  }

  Widget _buildAttendeeRow() {
    const maxAvatarsToShow = 3;
    final displayedAvatars = attendeeAvatars.take(maxAvatarsToShow).toList();

    return Row(
      children: [
        SizedBox(
          height: 30,
          width: maxAvatarsToShow * 20.0,
          child: Stack(
            children: displayedAvatars.asMap().entries.map((entry) {
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
        Text('+$goingCount Going', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
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
    );
  }
}