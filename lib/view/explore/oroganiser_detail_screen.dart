import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pgi/core/utils/status_bar_util.dart';
import 'package:pgi/services/api/xenforo_user_api.dart';
import 'package:pgi/view/message/create_message.dart';
import 'package:pgi/view/widgets/custom_app_bar.dart';
import 'package:pgi/view/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class OrganizerDetailsScreen extends StatefulWidget {
  final int userId;

  const OrganizerDetailsScreen({super.key, required this.userId});

  @override
  State<OrganizerDetailsScreen> createState() => _OrganizerDetailsScreenState();
}

class _OrganizerDetailsScreenState extends State<OrganizerDetailsScreen> {
  final XenForoUserApi userService = XenForoUserApi();
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    StatusBarUtil.setLightStatusBar();
    getUserById();
  }


  Future<void> getUserById() async {
    try {
      final user = await userService.getUserInfoById(widget.userId);
      setState(() {
        _userDetails = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // if (_userDetails == null) {
    //   return const Center(child: Text('Failed to load user details.'));
    // }

    final user = _userDetails!['user'];
    final avatarUrl = user['avatar_urls']['o'] ?? 'https://picsum.photos/201/200';
    final bannerUrl = user['profile_banner_urls']['l'] ?? 'https://picsum.photos/201/300';
    final fullName = '${user['custom_fields']['firstname']} ${user['custom_fields']['lastname']}';
    final nickname = user['username'] ?? 'No nickname';
    final isStaff = user['is_staff'] ? 'Staff Member' : 'Member';
    final website = user['website'] ?? '';
    final messageCount = user['message_count'] ?? 0;
    final reactionScore = user['reaction_score'] ?? 0;
    final trophyPoints = user['trophy_points']  ?? 0;
    final questionSolutionCount = user['question_solution_count'] ?? 0;
    final voteScore = user['vote_score'] ?? 0;
    final about = user['about'] ?? 'No about information provided.';

    return Scaffold(
    body: SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userDetails == null
              ? const Center(child: Text('Failed to load user details.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const CustomAppBarBody(
                        title: 'User Details',
                      ),
                      Stack(
                        children: [
                          Image.network(
                            bannerUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 100,
                            left: 16,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(avatarUrl),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        margin: const EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('@$nickname',
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: user['is_staff']
                                                ? Colors.blue
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            user['is_staff']
                                                ? 'Staff Member'
                                                : 'Member',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildPointTag(
                                  'Message Count',
                                  messageCount.toString(),
                                  Colors.blue),
                              _buildPointTag(
                                  'Reaction Score',
                                  reactionScore.toString(),
                                  Colors.green),
                              _buildPointTag(
                                  'Trophy Points',
                                  trophyPoints.toString(),
                                  Colors.orange),
                              _buildPointTag(
                                  'Question Solutions',
                                  questionSolutionCount.toString(),
                                  Colors.purple),
                              _buildPointTag(
                                  'Vote Score', voteScore.toString(), Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'About',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                about,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 20),
                              if (website.isNotEmpty)
                                InkWell(
                                  onTap: () => _launchURL(website),
                                  child: Text(
                                    website,
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              CustomButton(
                                label: 'Message',
                                padding: 5.0,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateMessageScreen(
                                        recipientId: [widget.userId],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    ),
  );
  }

  Widget _buildPointTag(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
