import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/screens/giftlist_page.dart';
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
  final Color primaryColor = const Color(0xFFFF7B7B); // Soft coral
  final Color secondaryColor = const Color(0xFF98D7C2); // Mint green
  final Color accentColor = const Color(0xFFE2D1F9); // Light purple
  final Color goldAccent = const Color(0xFFFFD700); // Gold
  final Color backgroundColor = const Color(0xFFFFFAF0); // Cream

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("${widget.friendName}'s Events",style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
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
                key: Key('event_$index'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.event,
                      color: primaryColor,
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
                subtitle: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: primaryColor),
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
                trailing: Container(
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GiftListPage(
                        eventId: event.id,
                        eventName: event.name,
                        eventDescription: event.description,
                        eventLocation: event.location,
                        eventDate: event.date,
                        isUpcoming: event.date.isAfter(DateTime.now()),
                      ),
                    ),
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
