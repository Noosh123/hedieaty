import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/screens/createEvent_page.dart';
import 'package:hedieaty/screens/myGiftlist_page.dart';
import 'package:hedieaty/services/local/local_event_service.dart';

class PrivateEventListPage extends StatefulWidget {
  @override
  _PrivateEventListPageState createState() => _PrivateEventListPageState();
}

class _PrivateEventListPageState extends State<PrivateEventListPage> {
  final LocalEventService _localEventService = LocalEventService();

  List<EventModel> _events = [];
  String _sortOption = 'name'; // Default sorting option
  bool _isLoading = true;
  final Set<String> _selectedEvents = {};

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  void _loadUserEvents() async {
    setState(() => _isLoading = true);

    try {
      final events = await _localEventService.getAllEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
      _sortEvents();
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  void _sortEvents() {
    setState(() {
      if (_sortOption == 'name') {
        _events.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortOption == 'category') {
        _events.sort((a, b) => a.category.compareTo(b.category));
      } else if (_sortOption == 'date') {
        _events.sort((a, b) => a.date.compareTo(b.date));
      }
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    await _localEventService.deleteEvent(eventId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted successfully!')),
    );
    _loadUserEvents();
  }

  Future<void> _publishSelectedEvents() async {
    // Logic to publish events to Firestore and delete from local DB
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedEvents.length} events published!')),
    );

    // After publishing, refresh the list
    _loadUserEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('My Private Events'),
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
                value: 'date',
                child: Text('Sort by Date'),
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
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Checkbox(
                value: _selectedEvents.contains(event.id),
                onChanged: (isChecked) {
                  setState(() {
                    if (isChecked == true) {
                      _selectedEvents.add(event.id);
                    } else {
                      _selectedEvents.remove(event.id);
                    }
                  });
                },
              ),
              title: Text(event.name),
              subtitle: Text(
                'Category: ${event.category}\n'
                    'Date: ${event.date.toLocal()}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateEventPage(event: event),
                      ),
                    ).then((_) => _loadUserEvents());
                  } else if (value == 'delete') {
                    await _deleteEvent(event.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyGiftListPage(
                      eventId: event.id,
                      isUpcoming: true,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.blue,
            heroTag: 'publishEvents',
            onPressed: _publishSelectedEvents,
            child: const Icon(Icons.cloud_upload, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: Colors.green,
            heroTag: 'createEvent',
            onPressed: () {
              Navigator.pushNamed(context, '/createPrivateEvent');
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
