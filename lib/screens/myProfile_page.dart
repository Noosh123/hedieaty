import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/event_service.dart';
import 'package:hedieaty/services/gift_service.dart';
import 'package:hedieaty/services/user_service.dart';
import 'package:hedieaty/services/image_service.dart';
import 'package:hedieaty/models/user_model.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final EventService _eventService = EventService();
  final GiftService _giftService = GiftService();
  final ImageService _imageService = ImageService();

  String? _userId;
  String? _name;
  String? _email;
  String? _profilePictureUrl = "https://via.placeholder.com/150";
  int _createdEventsCount = 0;
  int _pledgedGiftsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _userId = user.uid;

        // Fetch user data
        final userModel = await _userService.getUser(_userId!);
        if (userModel != null) {
          setState(() {
            _name = userModel.name;
            _email = userModel.email;
            _profilePictureUrl = userModel.profileImage.isNotEmpty
                ? userModel.profileImage
                : _profilePictureUrl;
          });
        }

        // Fetch created events count
        _eventService.getUserEvents(_userId!).listen((events) {
          setState(() {
            _createdEventsCount = events.length;
          });
        });

        // Fetch pledged gifts count
        _giftService.getPledgedGiftsByUser(_userId!).listen((gifts) {
          setState(() {
            _pledgedGiftsCount = gifts.length;
          });
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _requestPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final storagePermission = await Permission.storage.request();

    if (cameraPermission.isGranted && storagePermission.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and Storage permissions are required.')),
      );
      return false;
    }
  }

  Future<void> _uploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();

    // Request permissions first
    final hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    try {
      // Show dialog to choose between camera or gallery
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Select Image Source"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text("Gallery"),
            ),
          ],
        ),
      );

      if (source == null) return; // User dismissed the dialog

      // Pick the image based on the chosen source
      final XFile? pickedImage = await picker.pickImage(source: source);

      if (pickedImage != null) {
        setState(() => _isLoading = true); // Show loading indicator

        // Upload the image to ImgBB
        final imageUrl = await _imageService.uploadImage(pickedImage.path);

        if (imageUrl != null) {
          // Update the user's profile image URL in Firestore
          if (_userId != null) {
            await _userService.updateUserProfile(_userId!, {'profileImage': imageUrl});
          }

          setState(() => _profilePictureUrl = imageUrl);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        } else {
          throw Exception("Image upload failed");
        }
      }
    } catch (e) {
      print("Error uploading profile picture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile picture')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _updateEmail(String newEmail) async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        await _userService.updateUserProfile(user.uid, {'email': newEmail});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated successfully!')),
        );
      }
    } catch (e) {
      print("Error updating email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update email')),
      );
    }
  }

  Future<void> _saveProfile() async {
    try {
      if (_userId != null) {
        await _userService.updateUserProfile(_userId!, {'name': _name});
        if (_email != _authService.currentUser?.email) {
          await _updateEmail(_email!);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow[800],
          title: const Text('Profile'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: _uploadProfilePicture,
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
                filled: true,
                fillColor: Colors.purple.withOpacity(0.1),
                prefixIcon: const Icon(Icons.person),
                labelText: 'Name',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => _name = value,
            ),
            const SizedBox(height: 16),
            // User Email
            TextFormField(
              initialValue: _email,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.purple.withOpacity(0.1),
                prefixIcon: const Icon(Icons.email),
                labelText: 'Email',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => _email = value,
            ),
            const SizedBox(height: 16),
            // Created Events Section
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('My Events'),
              subtitle: Text('$_createdEventsCount Events'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, '/myEventlist');
              },
            ),
            const Divider(),
            // Created Private Events Section
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('My Private Events'),
              subtitle: Text('$_createdEventsCount Events'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, '/myPrivateEventlist');
              },
            ),
            const Divider(),
            // Pledged Gifts Section
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('My Pledged Gifts'),
              subtitle: Text('$_pledgedGiftsCount Gifts'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pushNamed(context, '/pledgedgifts');
              },
            ),
            const Divider(),
            const SizedBox(height: 16),
            // Save Changes Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[800],
                ),
                onPressed: _saveProfile,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
