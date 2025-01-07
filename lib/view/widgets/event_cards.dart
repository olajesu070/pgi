import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pgi/view/explore/event_detail_screen.dart';

class EventCard extends StatelessWidget {
  final int eventStartDate;
  final int eventEndDate;
  final String title;
  final String username;
  final String location;
  final String message;
  final String categoryTitle;
  final int viewCount;
  final int userId;

  const EventCard({
    super.key,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.title,
    required this.username,
    required this.location,
    required this.message,
    required this.categoryTitle,
    required this.viewCount,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final fEventStartDate = DateTime.fromMillisecondsSinceEpoch(eventStartDate);
    final fEventEndDate = DateTime.fromMillisecondsSinceEpoch(eventEndDate);
    final dateRange = DateFormat('d MMM, yyyy').format(fEventStartDate) +
        (fEventStartDate == fEventEndDate ? '' : ' - ${DateFormat('d MMM, yyyy').format(fEventEndDate)}');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailPage(
              title: title,
              date: dateRange,
              time: DateFormat('hh:mm a').format(fEventStartDate),
              centerName: categoryTitle,
              address: location,
              organizerName: username,
              eventDetails: message,
              userId: userId,
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
        padding: const EdgeInsets.all(12), 
        decoration: BoxDecoration(
           color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Stack(
          children: [
            _buildDateBox(),
          ],
        ),
        const SizedBox(height: 12), // Reduced spacing to decrease height
        _buildEventDetails(),
          ],
        ),
      ),
    );
    
  }

  Widget _buildDateBox() {
    final fEventStartDate = DateTime.fromMillisecondsSinceEpoch(eventStartDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10462F),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            DateFormat('d MMM, yyyy').format(fEventStartDate),
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.visibility, color: Colors.grey, size: 18),
            const SizedBox(width: 5),
            Text(
              '$viewCount views',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
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
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person, color: Colors.black, size: 14),
            const SizedBox(width: 5),
            Text(
              'Organizer: $username',
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        _buildLocationRow(),
      ],
    );
  }


  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Color(0xFFFF5252), size: 18),
        const SizedBox(width: 5),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xCC0A5338),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              location,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}