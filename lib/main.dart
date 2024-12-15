import 'package:flutter/material.dart';
import 'package:hedieaty/screens/eventlist_page.dart';
import 'package:hedieaty/screens/homepage.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes: {
        '/homepage': (context) => HomePage(),
        '/eventlist': (context) => EventListPage(),

      },
    );
  }
}
