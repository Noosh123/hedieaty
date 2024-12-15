import 'package:flutter/material.dart';

class PledgedGiftsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text('My Pledged Gifts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: 5, // Replace with dynamic count
          itemBuilder: (context, index) {
            final isPending = index % 2 == 0; // Example alternating status
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  Icons.card_giftcard,
                  color: isPending ? Colors.orange : Colors.green,
                ),
                title: Text('Gift ${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Friend: Friend ${index + 1}'),
                    Text('Due Date: ${DateTime.now().add(Duration(days: index * 2)).toLocal()}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'modify') {
                      // Handle modification logic
                      print('Modify pledge for Gift ${index + 1}');
                    } else if (value == 'remove') {
                      // Handle removal logic
                      print('Remove pledge for Gift ${index + 1}');
                    }
                  },
                  itemBuilder: (context) => [
                    if (isPending)
                      PopupMenuItem(
                        value: 'modify',
                        child: Text('Modify'),
                      ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
