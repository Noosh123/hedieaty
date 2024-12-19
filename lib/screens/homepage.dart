import 'package:flutter/material.dart';
import 'package:hedieaty/models/friend_model.dart';
import 'package:hedieaty/models/notification_model.dart';
import 'package:hedieaty/screens/eventlist_page.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/event_service.dart';
import 'package:hedieaty/services/friend_service.dart';
import 'package:hedieaty/services/authWrapper.dart';
import 'package:hedieaty/services/notification_service.dart';
import 'package:hedieaty/services/user_service.dart';
import 'package:hedieaty/services/gift_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();
  final EventService _eventService = EventService();
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final GiftService _giftService = GiftService();

  List<FriendModel> _friends = [];
  Map<String, int> _upcomingEventsCount = {};
  Map<String, String> _profileImages = {};
  List<FriendModel> _filteredFriends = [];
  List<NotificationModel> _notifications = [];

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFriendsAndEvents();
    _checkNotifications();
  }

  void _loadFriendsAndEvents() async {
    try {
      String currentUserId = _authService.currentUser!.uid;

      _friendService.getFriends(currentUserId).listen((friendsList) {
        setState(() {
          _friends = friendsList;
          _filteredFriends = friendsList;
        });

        // Fetch upcoming event counts and profile images
        for (var friend in friendsList) {
          // Fetch profile images
          _userService.getUser(friend.friendId).then((user) {
            if (user != null) {
              setState(() {
                _profileImages[friend.friendId] = user.profileImage;
              });
            }
          });

          // Fetch upcoming events count
          _eventService.getUserEvents(friend.friendId).listen((events) {
            final upcomingEvents = events
                .where((event) => event.date.isAfter(DateTime.now()))
                .toList();

            setState(() {
              _upcomingEventsCount[friend.friendId] = upcomingEvents.length;
            });
          });
        }
      });
    } catch (e) {
      print('Error fetching friends and events: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _checkNotifications() async {
    final currentUserId = _authService.currentUser!.uid;

    try {
      final notifications =
      await _notificationService.getNotifications(currentUserId);

      if (notifications.isNotEmpty) {
        setState(() {
          _notifications = notifications.reversed.toList();
        });

        // Show notifications in a modal pop-up
        _showNotificationPopup();

        // Clear notifications from Firestore after showing them
        await _notificationService.clearNotifications(currentUserId);
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  Future<void> _showNotificationPopup() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Notifications"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final message = notification.message;
                final keyword = notification.type == "pledge"
                    ? "pledged"
                    : "unpledged";

                // Split the message into parts
                final parts = message.split(keyword);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active,
                        color: Colors.blue),
                    title: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(text: parts[0]), // Text before the keyword
                          TextSpan(
                            text: keyword,
                            style: TextStyle(
                              color: notification.type == "pledge"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          if (parts.length > 1)
                            TextSpan(text: parts[1]), // Text after the keyword
                        ],
                      ),
                    ),
                    subtitle: Text(
                      'Time: ${notification.timestamp.toLocal()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }






  void _filterFriends(String query) {
    setState(() {
      _searchQuery = query;
      _filteredFriends = _friends
          .where((friend) =>
          friend.friendName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            await _authService.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AuthWrapper()),
                  (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully')),
            );
          },
          icon: const Icon(Icons.logout, size: 40),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow[800],
        title: const Text('Hedieaty'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin, size: 40),
            onPressed: () {
              Navigator.pushNamed(context, '/myprofile');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.purple.withOpacity(0.1),
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search friends...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: _filterFriends,
            ),
            const SizedBox(height: 8),
            // Friends List
            Expanded(
              child: _filteredFriends.isEmpty
                  ? const Center(child: Text('No friends found'))
                  : ListView.builder(
                itemCount: _filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = _filteredFriends[index];
                  final upcomingEvents = _upcomingEventsCount[friend.friendId] ?? 0;
                  final profileImage = _profileImages[friend.friendId] ?? '';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profileImage.isNotEmpty
                            ? NetworkImage(profileImage)
                            : const AssetImage('assets/default.png') as ImageProvider,
                      ),
                      title: Text(friend.friendName),
                      subtitle: Text('Upcoming Events: $upcomingEvents'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (upcomingEvents > 0)
                            const Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventListPage(
                              friendName: friend.friendName,
                              friendId: friend.friendId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Add Friend and Create Event Buttons
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.yellow[800],
                    heroTag: 'addFriend',
                    onPressed: () {
                      Navigator.pushNamed(context, '/addFriend');
                    },
                    child: const Icon(Icons.person_add),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    backgroundColor: Colors.green,
                    heroTag: 'createEvent',
                    onPressed: () {
                      Navigator.pushNamed(context, '/createEvent');
                    },
                    child: const Icon(
                      Icons.add_card_sharp,
                      color: Colors.white,
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
}
