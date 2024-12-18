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
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('My Events'),
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

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.event,
                color: status == 'Upcoming'
                    ? Colors.green
                    : (status == 'Current'
                    ? Colors.orange
                    : Colors.red),
              ),
              title: Text(event.name),
              subtitle: Text(
                'Category: ${event.category}\n'
                    'Status: $status\n'
                    'Date: ${event.date.toLocal()}',
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
