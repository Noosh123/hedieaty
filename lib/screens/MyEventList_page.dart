import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/screens/createEvent_page.dart';
import 'package:hedieaty/screens/myGiftlist_page.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/event_service.dart';

class MyEventListPage extends StatefulWidget {
  @override
  _MyEventListPageState createState() => _MyEventListPageState();
}

class _MyEventListPageState extends State<MyEventListPage> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  final Color primaryColor = const Color(0xFFFF7B7B); // Soft coral
  final Color secondaryColor = const Color(0xFF98D7C2); // Mint green
  final Color accentColor = const Color(0xFFE2D1F9); // Light purple
  final Color goldAccent = const Color(0xFFFFD700); // Gold
  final Color backgroundColor = const Color(0xFFFFFAF0); // Cream

  List<EventModel> _events = [];
  String _sortOption = 'name'; // Default sorting option
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  void _loadUserEvents() {
    final String currentUserId = _authService.currentUser!.uid;

    // Fetch user's events
    _eventService.getUserEvents(currentUserId).listen((eventList) {
      setState(() {
        _events = eventList;
        _isLoading = false;
      });
      _sortEvents();
    });
  }

  void _sortEvents() {
    setState(() {
      if (_sortOption == 'name') {
        _events.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortOption == 'category') {
        _events.sort((a, b) => a.category.compareTo(b.category));
      } else if (_sortOption == 'status') {
        _events.sort((a, b) => _getEventStatus(a).compareTo(_getEventStatus(b)));
      }
    });
  }

  String _getEventStatus(EventModel event) {
    final now = DateTime.now();
    if (event.date.isAfter(now)) {
      return 'Upcoming';
    } else if (event.date.isBefore(now)) {
      return 'Past';
    } else {
      return 'Current';
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    await _eventService.deleteEvent(eventId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('My Events',style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
              _sortEvents();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Text('Sort by Category'),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Text('Sort by Status'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text('No events found'))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final status = _getEventStatus(event);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: status == 'Upcoming'
                        ? Colors.green
                        : (status == 'Current' ? Colors.orange : Colors.red),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: status == 'Upcoming'
                      ? Colors.green.withOpacity(0.1)
                      : (status == 'Current'
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1)),
                  child: Icon(
                    Icons.event,
                    color: status == 'Upcoming'
                        ? Colors.green
                        : (status == 'Current' ? Colors.orange : Colors.red),
                    size: 28,
                  ),
                ),
              ),
              title: Text(
                event.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category: ${event.category}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    'Status: $status',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Date: ${event.date.toLocal()}'.split(' ')[1],
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEventPage(event: event),
                      ),
                    );
                  } else if (value == 'delete') {
                    await _deleteEvent(event.id!);
                  }
                },
                itemBuilder: (context) {
                  List<PopupMenuItem<String>> menuItems = [];
                  if (status == 'Upcoming') {
                    menuItems.add(
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                    );
                  }
                  menuItems.add(
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  );
                  return menuItems;
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyGiftListPage(
                      eventId: event.id,
                      isUpcoming: _getEventStatus(event) == 'Upcoming',
                    ),
                  ),
                );
              },
            ),
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        heroTag: 'createEvent',
        onPressed: () {
          Navigator.pushNamed(context, '/createEvent');
        },
        child: const Icon(Icons.add_card_sharp, color: Colors.white),
      ),
    );
  }
}
