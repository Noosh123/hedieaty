import 'package:flutter/material.dart';

class GiftDetailsPage extends StatefulWidget {
  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  bool _isPledged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text('Gift Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gift Image Placeholder
            Center(
              child: Icon(
                Icons.card_giftcard,
                size: 150,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Gift Name
            Text(
              'Gift Name (Static)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              'This is a static description of the gift. Replace with dynamic data later.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Category
            Text(
              'Category: Electronics (Static)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Price
            Text(
              'Price: \$99.99 (Static)',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Pledge/Unpledge Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPledged ? Colors.red : Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    _isPledged = !_isPledged;
                  });
                },
                child: Text(
                  _isPledged ? 'Unpledge' : 'Pledge',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
