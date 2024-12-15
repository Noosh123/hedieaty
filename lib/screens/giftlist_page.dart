import 'package:flutter/material.dart';

class GiftListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text('Gift List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle sorting logic
              print('Sort by: $value');
            },
            itemBuilder: (context) => [
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
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150', // Replace with gift image URL
                  ),
                  radius: 30,
                ),
                title: Text('Gift ${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: Electronics'),
                    Text('Price: \$${(index + 1) * 10}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: index.isEven ? Colors.green : Colors.yellow, // Status indicator
                      size: 16,
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        // Handle edit/delete
                        print('$value for Gift ${index + 1}');
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to Gift Details Page
                  Navigator.pushNamed(context, '/giftdetails');
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Gift Page
          print('Add Gift');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
