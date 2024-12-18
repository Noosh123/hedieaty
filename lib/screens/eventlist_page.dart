import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/services/event_service.dart';

class EventListPage extends StatefulWidget {
  final String friendName;
  final String friendId;

  const EventListPage({Key? key, required this.friendName, required this.friendId})
      : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventService _eventService = EventService();
  List<EventModel> _upcomingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpcomingEvents();
  }

  void _loadUpcomingEvents() {
    _eventService
        .getUserEvents(widget.friendId)
        .listen((events) {
      final now = DateTime.now();
      setState(() {
        _upcomingEvents = events
            .where((event) => event.date.isAfter(now))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date)); // Sort by date
        _isLoading = false;
      });
    }).onError((error) {
      print("Error fetching upcoming events: $error");
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text("${widget.friendName}'s Events"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _upcomingEvents.isEmpty
          ? const Center(
        child: Text(
          'No Upcoming Events',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: _upcomingEvents.length,
          itemBuilder: (context, index) {
            final event = _upcomingEvents[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.event,
                  color: Colors.green, // Status indicator for upcoming events
                ),
                title: Text(event.name),
                subtitle: Text(
                  'Date: ${event.date.toLocal()}'.split(' ')[1],
                ),
                onTap: () {
                  // Navigate to Gift List Page
                  Navigator.pushNamed(
                    context,
                    '/giftlist',
                    arguments: {'eventId': event.id, 'isUpcoming': true},
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
