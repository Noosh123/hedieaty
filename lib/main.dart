import 'package:flutter/material.dart';
import 'package:hedieaty/screens/eventlist_page.dart';
import 'package:hedieaty/screens/giftdetails_page.dart';
import 'package:hedieaty/screens/giftlist_page.dart';
import 'package:hedieaty/screens/homepage.dart';
import 'package:hedieaty/screens/myPledgedGifts_page.dart';
import 'package:hedieaty/screens/myProfile_page.dart';

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
        '/giftlist':(context) => GiftListPage(),
        '/giftdetails':(context) => GiftDetailsPage(),
        '/myprofile':(context) => ProfilePage(),
        '/mppledgedgifts':(context) => PledgedGiftsPage(),

      },
    );
  }
}
