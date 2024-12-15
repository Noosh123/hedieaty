import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.yellow[800],
        title: const Text('Hedieaty'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin, size: 40),
            onPressed: () {
              // Navigate to Profile Page
              Navigator.pushNamed(context, '/myprofile');
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
                prefixIcon: const Icon(Icons.search),
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
                  // Simulate upcoming events count
                  final int upcomingEvents = index % 3; // Example logic

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150', // Replace with friend's image URL
                        ),
                      ),
                      title: Text('Friend $index'),
                      subtitle: Text('Upcoming Events: $upcomingEvents'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (upcomingEvents > 0)
                            const Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 16,
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                      onTap: () {
                        // Navigate to Friend's Event List
                        Navigator.pushNamed(context, '/eventlist');
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // FAB for adding a new friend
                  FloatingActionButton(
                    backgroundColor: Colors.yellow[800],
                    heroTag: 'addFriend',
                    onPressed: () {
                      // Navigate to Add Friend Page
                      Navigator.pushNamed(context, '/addFriend');
                    },
                    child: const Icon(Icons.person_add),
                  ),
                  const SizedBox(height: 16),
                  // FAB for creating a new event
                  FloatingActionButton(
                    backgroundColor: Colors.green,
                    heroTag: 'createEvent',
                    onPressed: () {
                      // Navigate to Create Event Page
                      Navigator.pushNamed(context, '/createEvent');
                    },
                    child: const Icon(
                      Icons.add_card_sharp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
