import 'package:flutter/material.dart';
import 'package:hedieaty/models/friend_model.dart';
import 'package:hedieaty/screens/eventlist_page.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/event_service.dart';
import 'package:hedieaty/services/friend_service.dart';
import 'package:hedieaty/services/authWrapper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();
  final EventService _eventService = EventService();

  List<FriendModel> _friends = [];
  Map<String, int> _upcomingEventsCount = {};
  List<FriendModel> _filteredFriends = [];

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFriendsAndEvents();
  }

  // Fetch friends and their upcoming events count using EventService
  void _loadFriendsAndEvents() async {
    try {
      String currentUserId = _authService.currentUser!.uid;

      // Listen to the friends list using FriendService
      _friendService.getFriends(currentUserId).listen((friendsList) {
        setState(() {
          _friends = friendsList;
          _filteredFriends = friendsList;
        });

        // Fetch upcoming event counts using EventService
        for (var friend in friendsList) {
          _eventService.getUserEvents(friend.friendId).listen((events) {
            // Filter only upcoming events
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
                  final upcomingEvents =
                      _upcomingEventsCount[friend.friendId] ?? 0;

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage(
                            'assets/default.png'), // Placeholder image
                      ),
                      title: Text(friend.friendName),
                      subtitle:
                      Text('Upcoming Events: $upcomingEvents'),
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
                //color: Colors.purple.withOpacity(0.1),
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
