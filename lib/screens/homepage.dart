import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('Hedieaty - Friends'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to Profile Page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search friends...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: (value) {
                // Perform search
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with dynamic count
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150', // Replace with friend's image URL
                        ),
                      ),
                      title: Text('Friend $index'),
                      subtitle: Text('Upcoming Events: ${index % 2}'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to Friend's Event List
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Event/List Page
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
