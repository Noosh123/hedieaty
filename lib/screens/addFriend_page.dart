import 'package:flutter/material.dart';
import 'package:hedieaty/services/friend_service.dart';
import 'package:hedieaty/services/auth_service.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final FriendService _friendService = FriendService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  final Color primaryColor = const Color(0xFFFF7B7B); // Soft coral
  final Color secondaryColor = const Color(0xFF98D7C2); // Mint green
  final Color accentColor = const Color(0xFFE2D1F9); // Light purple
  final Color backgroundColor = const Color(0xFFFFFAF0); // Cream

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addFriend() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String currentUserId = _authService.currentUser!.uid;

        bool success = await _friendService.addFriend(
          currentUserId: currentUserId,
          friendPhoneNumber: _phoneController.text.trim(),
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend added successfully!')),
          );
          _phoneController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend not found or already exists!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Add Friend',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, accentColor.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_add, color: primaryColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Add a Friend',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('phone_field'),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: accentColor.withOpacity(0.1),
                    hintText: 'Enter friend\'s phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon:  Icon(Icons.phone, color: primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                      return 'Enter a valid phone number (10-15 digits)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                    key: const Key('add_friend_button2'),
                    onPressed: _addFriend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add Friend',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
