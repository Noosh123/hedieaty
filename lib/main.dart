import 'package:flutter/material.dart';
import 'package:hedieaty/screens/MyEventList_page.dart';
import 'package:hedieaty/screens/addGift.dart';
import 'package:hedieaty/screens/createEvent_page.dart';
import 'package:hedieaty/screens/eventlist_page.dart';
import 'package:hedieaty/screens/giftdetails_page.dart';
import 'package:hedieaty/screens/giftlist_page.dart';
import 'package:hedieaty/screens/homepage.dart';
import 'package:hedieaty/screens/myGiftlist_page.dart';
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
        '/eventlist': (context) => EventListPage(friendName: 'Friend Name'),
        '/myEventlist': (context) => MyEventListPage(),// Pass dynamic name later
        '/giftlist':(context) => GiftListPage(),
        '/myGiftlist': (context) => MyGiftListPage(),
        '/giftdetails':(context) => GiftDetailsPage(),
        '/myprofile':(context) => ProfilePage(),
        '/pledgedgifts':(context) => PledgedGiftsPage(),
        '/createEvent': (context) => CreateEventPage(),
        '/addGift': (context) => createGift(),

      },
    );
  }
}
