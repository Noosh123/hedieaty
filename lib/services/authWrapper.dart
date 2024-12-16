import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/screens/homepage.dart';
import 'package:hedieaty/screens/authentication/sign_in_page.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService(); // Instance of AuthService

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges, // Use authStateChanges from AuthService
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while Firebase initializes
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is logged in
          return HomePage();
        } else {
          // User is not logged in
          return SignInScreen();
        }
      },
    );
  }
}
