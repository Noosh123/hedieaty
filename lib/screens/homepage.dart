import 'dart:async';

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
  List<StreamSubscription> _subscriptions = [];

  bool _isLoading = true;
  String _searchQuery = '';
  // Add these color constants at the top of the class
  final Color primaryColor = const Color(0xFFFF7B7B); // Soft coral
  final Color secondaryColor = const Color(0xFF98D7C2); // Mint green
  final Color accentColor = const Color(0xFFE2D1F9); // Light purple
  final Color goldAccent = const Color(0xFFFFD700); // Gold
  final Color backgroundColor = const Color(0xFFFFFAF0); // Cream

  @override
  void initState() {
    super.initState();
    _loadFriendsAndEvents();
    _checkNotifications();
  }

  void _loadFriendsAndEvents() async {
    try {
      String currentUserId = _authService.currentUser!.uid;

      final friendsSubscription = _friendService.getFriends(currentUserId).listen((friendsList) {
        if (!mounted) return; // Prevent setState if the widget is disposed
        setState(() {
          _friends = friendsList;
          _filteredFriends = friendsList;
        });

        for (var friend in friendsList) {
          // Fetch profile images
          _userService.getUser(friend.friendId).then((user) {
            if (!mounted) return;
            if (user != null) {
              setState(() {
                _profileImages[friend.friendId] = user.profileImage;
              });
            }
          });

          // Fetch upcoming events count
          final eventsSubscription = _eventService.getUserEvents(friend.friendId).listen((events) {
            final upcomingEvents = events.where((event) => event.date.isAfter(DateTime.now())).toList();

            if (!mounted) return;
            setState(() {
              _upcomingEventsCount[friend.friendId] = upcomingEvents.length;
            });
          });

          // Store the event subscription for cancellation
          _subscriptions.add(eventsSubscription);
        }
      });

      // Store the friends subscription for cancellation
      _subscriptions.add(friendsSubscription);
    } catch (e) {
      print('Error fetching friends and events: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  void dispose() {
    // Cancel all active subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('logout_button'),
          onPressed: () async {
            await _authService.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AuthWrapper()),
                  (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Logged out successfully'),
                backgroundColor: primaryColor,
              ),
            );
          },
          icon: const Icon(Icons.logout, size: 40, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Hedieaty',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('profile_button'),
            icon: const Icon(Icons.person_pin, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/myprofile');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundColor, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Field with festive design
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: TextField(
                  key: const Key('search_bar'),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    hintText: 'Search friends...',
                    hintStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                  onChanged: _filterFriends,
                ),
              ),
              const SizedBox(height: 16),
              // Friends List with festive cards
              Expanded(
                child: _filteredFriends.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard,
                          size: 64, color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'No friends found',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: _filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = _filteredFriends[index];
                    final upcomingEvents =
                        _upcomingEventsCount[friend.friendId] ?? 0;
                    final profileImage =
                        _profileImages[friend.friendId] ?? '';

                    return Container(
                      margin:
                      const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, accentColor.withOpacity(0.2)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        key: Key('friend_$index'),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: goldAccent,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage: profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : const NetworkImage(
                                'https://i.ibb.co/GFK3bM1/istockphoto-1332100919-612x612.jpg'),
                          ),
                        ),
                        title: Text(
                          friend.friendName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.card_giftcard,
                                size: 16, color: secondaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'Upcoming Events: $upcomingEvents',
                              style: TextStyle(
                                color: Colors.green[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (upcomingEvents > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 12,
                                ),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.arrow_forward,
                                color: primaryColor,
                              ),
                            ),
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
              // Bottom Action Buttons with festive design
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: Icons.person_add,
                      color: primaryColor,
                      onPressed: () {
                        Navigator.pushNamed(context, '/addFriend');
                      },
                      key: 'add_friend_button',
                    ),
                    _buildActionButton(
                      icon: Icons.add_card_sharp,
                      color: secondaryColor,
                      onPressed: () {
                        Navigator.pushNamed(context, '/createEvent');
                      },
                      key: 'create_event_button',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String key,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton(
        key: Key(key),
        backgroundColor: color,
        heroTag: key,
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white, size: 28),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}