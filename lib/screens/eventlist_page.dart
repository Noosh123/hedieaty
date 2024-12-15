import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  final String friendName;

  const EventListPage({Key? key, required this.friendName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text("$friendName's Events"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: 5, // Replace with dynamic count
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  Icons.event,
                  color: index.isEven ? Colors.green : Colors.red, // Status indicator
                ),
                title: Text('Event ${index + 1}'),
                subtitle: Text('Date: ${DateTime.now().toLocal()}'),
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
