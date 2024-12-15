import 'package:flutter/material.dart';

class GiftListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('Gift List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle sorting logic
              print('Sort by: $value');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              PopupMenuItem(
                value: 'category',
                child: Text('Sort by Category'),
              ),
              PopupMenuItem(
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
            // Example gift status (available or pledged)
            final isAvailable = index % 2 == 0; // Replace with dynamic logic later

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: const NetworkImage(
                    'https://via.placeholder.com/150', // Replace with gift image URL
                  ),
                  radius: 30,
                ),
                title: Text('Gift ${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category: Electronics'),
                    const Text('Price: \$99.99'), // Static placeholder
                    Text(
                      isAvailable ? 'Available' : 'Pledged',
                      style: TextStyle(
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.circle,
                  color: isAvailable ? Colors.green : Colors.yellow, // Status indicator
                  size: 16,
                ),
                onTap: isAvailable
                    ? () {
                  // Navigate to Gift Details Page
                  Navigator.pushNamed(context, '/giftdetails');
                }
                    : null, // Disable tap if not available
              ),
            );
          },
        ),
      ),
    );
  }
}
