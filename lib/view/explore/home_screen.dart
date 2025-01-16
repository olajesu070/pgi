import 'dart:math';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:pgi/core/constants/app_colors.dart';
import 'package:pgi/data/models/user_state.dart';
import 'package:pgi/services/api/xenforo_api_service.dart';
import 'package:pgi/services/api/xenforo_event_service.dart';
import 'package:pgi/services/api/xenforo_user_api.dart';
import 'package:pgi/view/discussion/discussion.dart';
import 'package:pgi/view/widgets/custom_drawer.dart';
import 'package:pgi/view/widgets/edge_button.dart';
import 'package:pgi/view/widgets/event_cards.dart';
import 'package:pgi/view/misc/notification_screen.dart';
import 'package:pgi/view/widgets/post_cards.dart';
import 'package:pgi/view/widgets/section_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final XenForoApiService apiService = XenForoApiService();
  final XenforoEventService eventService = XenforoEventService();
  final XenForoUserApi userApiService = XenForoUserApi();

  List<Map<String, dynamic>> discussions = [];
  List<dynamic> events = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDiscussions();
    _fetchEvents();
    // Fetch user details on page load
    Provider.of<UserState>(context, listen: false).fetchUserDetails();
  }

  Future<void> _fetchDiscussions() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await apiService.getForumThreads();

      setState(() {
        if (data['threads'].isEmpty) {
          discussions = [];
          errorMessage = 'No discussions available at the moment.';
        } else {
          discussions = List<Map<String, dynamic>>.from(data['threads']);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load discussions. Please try again later.';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await eventService.fetchEvents();
      final fetchedEvents = response['events'] as List<dynamic>;

      setState(() {
        events.addAll(fetchedEvents);
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

 

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    final userDetails = userState.userDetails ?? {};
    return Scaffold(
      drawer: CustomDrawer(userDetails: userDetails),
      body: SafeArea(
        child: Stack(
          children: [
            Container(color: const Color(0xFFFFFFFF)),
            _buildHeader(context),
            _buildEdgeButtons(),
            Padding(
              padding: const EdgeInsets.only(top: 150), // Adjust based on overlay height
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 10),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SectionWidget(
                          title: 'Upcoming Events',
                          actionText: 'See All',
                          onTap: () => Navigator.pushNamed(context, '/schedule'),
                          content: _buildEventCards(),
                        ),
                        SectionWidget(
                          title: 'Latest Posts',
                          actionText: '',
                          content: _buildPostCards(context),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    final userDetails = userState.userDetails ?? {};
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(33),
            bottomRight: Radius.circular(33),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFFFFFF),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    color: const Color(0xFFFFFFFF),
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${toBeginningOfSentenceCase<String?>(userDetails['me']['custom_fields']['city'])}',
                        style: const TextStyle(fontSize: 14, color: Colors.white,),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                    ),
                  );
                  },
                  child: const CircleAvatar(
                  backgroundColor: Color(0x49FFFFFF),
                  child: Icon(Icons.notifications_none, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     // Expanded(
            //     //   child: TextField(
            //     //     decoration: InputDecoration(
            //     //       hintText: 'Search...',
            //     //       hintStyle: const TextStyle(color: Colors.white),
            //     //       prefixIcon: const Icon(Icons.search, color: Colors.white),
            //     //       filled: true,
            //     //       fillColor: Colors.transparent,
            //     //       border: OutlineInputBorder(
            //     //         borderRadius: BorderRadius.circular(30),
            //     //         borderSide: BorderSide.none,
            //     //       ),
            //     //       contentPadding: const EdgeInsets.symmetric(vertical: 12),
            //     //     ),
            //     //     style: const TextStyle(color: Colors.white),
            //     //   ),
            //     // ),
            //     // const SizedBox(width: 10),
            //     // ElevatedButton(
            //     //   onPressed: () {},
            //     //   style: ElevatedButton.styleFrom(
            //     //     shape: RoundedRectangleBorder(
            //     //       borderRadius: BorderRadius.circular(30),
            //     //     ),
            //     //     backgroundColor: const Color(0xFF0A5338),
            //     //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            //     //   ),
            //     //   child: Row(
            //     //     mainAxisSize: MainAxisSize.min,
            //     //     children: [
            //     //       Container(
            //     //         decoration: const BoxDecoration(
            //     //           color: Colors.white,
            //     //           shape: BoxShape.circle,
            //     //         ),
            //     //         padding: const EdgeInsets.all(5),
            //     //         child: const Icon(
            //     //           Icons.filter_list,
            //     //           color: Color(0xFF0A5338),
            //     //           size: 20,
            //     //         ),
            //     //       ),
            //     //       const SizedBox(width: 5),
            //     //       const Text(
            //     //         'Filter',
            //     //         style: TextStyle(color: Colors.white),
            //     //       ),
            //     //     ],
            //     //   ),
            //     // ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildEdgeButtons() {
    return const Positioned(
      top: 90,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          EdgeButton(color: Color(0xFFF44336), text: 'The Guild', param: 17),
          EdgeButton(color: Color(0xFFF59762), text: 'Convention', param: 47),
          EdgeButton(color: Color(0xFF29D697), text: 'Lodging', param: 55),
        ],
      ),
    );
  }

  Widget _buildEventCards() {
    if (events.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No events available.')),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: min(events.length, 4), // Limit to at most 4 events
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(
           title: event['title'] ?? 'No Title',
            username: event['username'] ?? 'Unknown',
            location: event['event_timezone'] ?? 'Location not specified',
            eventStartDate: event['event_start_date'] * 1000,
            eventEndDate: event['event_end_date'] * 1000,
            message: event['message'] ?? 'No description provided.',
            categoryTitle: event['Category']?['title'] ?? 'General',
            viewCount: event['view_count'] ?? 0,
            userId: event['user_id'],
           );
        },
      ),
    );
  }

  Widget _buildPostCards(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (discussions.isEmpty) {
      return Center(
        child: Text(
          errorMessage.isNotEmpty ? errorMessage : 'No discussions available.',
        ),
      );
    }


return ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  itemCount: min(discussions.length, 5), // Limit to at most 5 posts
  itemBuilder: (context, index) {
    final discussion = discussions[index];
    final user = discussion['User'];
    final formattedDate = DateFormat('MMM dd, yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(discussion['post_date'] * 1000),
    );

    return LatestPostCard(
      imageUrl: user?['avatar_urls']?['s'] ?? 'https://picsum.photos/201/300',
      date: formattedDate,
      time: DateFormat('hh:mm a').format(
        DateTime.fromMillisecondsSinceEpoch(discussion['post_date'] * 1000),
      ),
      title: discussion['title']!,
      writerName: discussion['username']!,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscussionDetailScreen(threadId: discussion['thread_id']),
          ),
        );
      },
    );
  },
);

  }
}

