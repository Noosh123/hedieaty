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
            // Example event status (Upcoming, Current, Past)
            final status = index % 3 == 0
                ? 'Upcoming'
                : (index % 3 == 1 ? 'Current' : 'Past'); // Replace with dynamic data

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  Icons.event,
                  color: status == 'Upcoming'
                      ? Colors.green
                      : (status == 'Current' ? Colors.orange : Colors.red), // Status indicator
                ),
                title: Text('Event ${index + 1}'),
                subtitle: Text('Status: $status\nDate: ${DateTime.now().toLocal()}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle edit/delete
                    print('$value for Event ${index + 1}');
                  },
                  itemBuilder: (context) {
                    // Conditionally add "Edit" option for upcoming events
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
                  // Navigate to Gift List Page
                  Navigator.pushNamed(context, '/myGiftlist');
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
