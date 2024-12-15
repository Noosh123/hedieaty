import 'package:flutter/material.dart';

class MyEventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('My Events'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle sorting/filtering logic
              print('Selected: $value');
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
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle edit/delete
                    print('$value for Event ${index + 1}');
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
                  // Navigate to Gift List Page
                  Navigator.pushNamed(context, '/giftlist');
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        heroTag: 'createEvent',
        onPressed: () {
          // Navigate to Create Event Page
          Navigator.pushNamed(context, '/createEvent');
        },
        child: const Icon(Icons.add_card_sharp, color: Colors.white),
      ),
    );
  }
}
