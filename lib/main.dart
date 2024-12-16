import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/screens/MyEventList_page.dart';
import 'package:hedieaty/screens/addFriend_page.dart';
import 'package:hedieaty/screens/addGift.dart';
import 'package:hedieaty/screens/createEvent_page.dart';
import 'package:hedieaty/screens/eventlist_page.dart';
import 'package:hedieaty/screens/giftdetails_page.dart';
import 'package:hedieaty/screens/giftlist_page.dart';
import 'package:hedieaty/screens/homepage.dart';
import 'package:hedieaty/screens/myGiftlist_page.dart';
import 'package:hedieaty/screens/myPledgedGifts_page.dart';
import 'package:hedieaty/screens/myProfile_page.dart';
import 'package:hedieaty/services/authWrapper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: AuthWrapper(),
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
        '/addFriend': (context) => AddFriendScreen(),


      },
    );
  }
}
