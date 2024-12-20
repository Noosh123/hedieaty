import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scenario 1 Integration Test', (WidgetTester tester) async {
    // Step 1: Launch the app using runApp
    await app.main();
    await tester.pumpAndSettle();


    await tester.pump(const Duration(seconds: 6));

    // Step 2: User enters email and password in sign in page and presses login
    final emailField = find.byKey(const Key('email_field'));
    final passwordField = find.byKey(const Key('password_field'));
    final loginButton = find.byKey(const Key('login_button'));

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    await tester.enterText(emailField, 'mama@gmail.com');
    await tester.enterText(passwordField, '123456789');
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Step 3: User presses the add friend button in the homepage
    final addFriendButton = find.byKey(const Key('add_friend_button'));
    expect(addFriendButton, findsOneWidget);
    await Future.delayed(const Duration(seconds: 3));
    await tester.tap(addFriendButton);
    await tester.pumpAndSettle();

    // Step 4: User adds a certain friend with a certain phone number x
    final phoneNumberField = find.byKey(const Key('phone_field'));
    final addFriendSubmitButton = find.byKey(const Key('add_friend_button2'));
    expect(phoneNumberField, findsOneWidget);
    expect(addFriendSubmitButton, findsOneWidget);

    await tester.enterText(phoneNumberField, '01201169703');
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(addFriendSubmitButton);
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    // Step 5: User is now in the homepage
    final searchField = find.byKey(const Key('search_bar'));
    expect(searchField, findsOneWidget);

    // Step 6: User uses the search bar and types a friend's name Y
    await tester.enterText(searchField, 'Anas');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    // Step 7: User clicks on the first friend that appears
    final firstFriend = find.byKey(const Key('friend_0'));
    expect(firstFriend, findsOneWidget);
    await tester.tap(firstFriend);
    await tester.pumpAndSettle();

    // Step 8: User is now in the event list page
    final firstEvent = find.byKey(const Key('event_0'));
    expect(firstEvent, findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    // Step 9: User clicks on the first event
    await tester.tap(firstEvent);
    await tester.pumpAndSettle();

    // Step 10: User is now in gift list page
    final firstGift = find.byKey(const Key('gift_0'));
    expect(firstGift, findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    // Step 11: User clicks on the first gift
    await tester.tap(firstGift);
    await tester.pumpAndSettle();

    // Step 12: User is now in the gift details page
    final pledgeButton = find.byKey(const Key('gift_pledge_button'));
    expect(pledgeButton, findsOneWidget);

    // Step 13: User clicks on the pledge button
    await tester.tap(pledgeButton);
    await tester.pumpAndSettle();

    // Step 14: User clicks on the back button to go back to gift list page
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Step 15: User clicks on the back button to go back to event list page
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Step 16: User clicks on the back button to go back to the homepage
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Verify user is back in the homepage
    expect(searchField, findsOneWidget);
  });
}