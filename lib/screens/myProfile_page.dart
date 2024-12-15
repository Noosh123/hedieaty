import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _name = "John Doe"; // Replace with dynamic data
  String? _email = "john.doe@example.com"; // Replace with dynamic data
  String? _profilePictureUrl =
      "https://via.placeholder.com/150"; // Replace with dynamic data
  int _createdEventsCount = 5; // Replace with dynamic data
  int _pledgedGiftsCount = 3; // Replace with dynamic data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: () {
                  // Implement image picker functionality
                  print('Change profile picture');
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_profilePictureUrl!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // User Name
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _name = value,
            ),
            const SizedBox(height: 16),
            // User Email
            TextFormField(
              initialValue: _email,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _email = value,
            ),
            const SizedBox(height: 16),
            // Created Events Section
            ListTile(
              leading: Icon(Icons.event),
              title: Text('My Created Events'),
              subtitle: Text('$_createdEventsCount Events'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to Created Events Page
                Navigator.pushNamed(context, '/created-events');
              },
            ),
            const Divider(),
            // Pledged Gifts Section
            ListTile(
              leading: Icon(Icons.card_giftcard),
              title: Text('My Pledged Gifts'),
              subtitle: Text('$_pledgedGiftsCount Gifts'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to Pledged Gifts Page
                Navigator.pushNamed(context, '/pledged-gifts');
              },
            ),
            const Divider(),
            const SizedBox(height: 16),
            // Save Changes Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[800]
                ),
                onPressed: () {
                  // Save updated profile details to Firestore
                  print('Saving profile: Name=$_name, Email=$_email');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully!')),
                  );
                },
                child: Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
