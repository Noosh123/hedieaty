import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  final String friendName;

   EventListPage({Key? key, required this.friendName}) : super(key: key);

  // Example event data (Replace with dynamic data from a database or API)
  final List<Map<String, dynamic>> events = [
    {
      'title': 'Birthday Party',
      'date': DateTime.now().add(Duration(days: 1)), // Upcoming
      'status': 'Upcoming'
    },
    {
      'title': 'Wedding Anniversary',
      'date': DateTime.now().subtract(Duration(days: 5)), // Past
      'status': 'Past'
    },
    {
      'title': 'Graduation Ceremony',
      'date': DateTime.now().add(Duration(days: 7)), // Upcoming
      'status': 'Upcoming'
    },
    {
      'title': 'Company Meetup',
      'date': DateTime.now().subtract(Duration(days: 10)), // Past
      'status': 'Past'
    },
    {
      'title': 'Holiday Celebration',
      'date': DateTime.now().add(Duration(days: 3)), // Upcoming
      'status': 'Upcoming'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter the list to include only upcoming events
    final upcomingEvents = events.where((event) {
      return event['status'] == 'Upcoming';
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text("$friendName's Events"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: upcomingEvents.isEmpty
            ? Center(
          child: Text(
            'No Upcoming Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : ListView.builder(
          itemCount: upcomingEvents.length,
          itemBuilder: (context, index) {
            final event = upcomingEvents[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  Icons.event,
                  color: Colors.green, // Status indicator for upcoming events
                ),
                title: Text(event['title']),
                subtitle: Text(
                  'Date: ${event['date'].toLocal()}'.split(' ')[1],
                ),
                onTap: () {
                  // Navigate to Gift List Page
                  Navigator.pushNamed(context, '/giftlist');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
