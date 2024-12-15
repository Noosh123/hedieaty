import 'package:flutter/material.dart';

class MyGiftListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('My Gift List'),
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
            final isAvailable = index % 2 == 0; // Replace with dynamic status

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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: isAvailable ? Colors.green : Colors.yellow, // Status indicator
                      size: 16,
                    ),
                    if (isAvailable)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            // Navigate to Edit Gift Page
                            Navigator.pushNamed(context, '/addGift'); // Replace with actual edit logic
                          } else if (value == 'delete') {
                            // Show confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to delete this gift?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close dialog
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Perform delete operation
                                        print('Gift ${index + 1} deleted');
                                        Navigator.of(context).pop(); // Close dialog
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
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
                  ],
                ),
                // onTap: isAvailable
                //     ? () {
                //   // Navigate to Gift Details Page
                //   //Navigator.pushNamed(context, '/giftdetails');
                // }
                //     : null, // Disable tap if not available
              ),
            );
          },
        ),
      ),
      // Add Gift Button at the bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () {
            // Navigate to Add Gift Page
            Navigator.pushNamed(context, '/addGift');
          },
          child: const Text(
            'Add New Gift',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
