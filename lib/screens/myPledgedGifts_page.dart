import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/models/user_model.dart';
import 'package:hedieaty/screens/giftdetails_page.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/gift_service.dart';
import 'package:hedieaty/services/event_service.dart';
import 'package:hedieaty/services/user_service.dart';


class PledgedGiftsPage extends StatefulWidget {
  const PledgedGiftsPage({Key? key}) : super(key: key);

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final GiftService _giftService = GiftService();
  final EventService _eventService = EventService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  List<GiftModel> _gifts = [];
  Map<String, EventModel> _eventDetails = {};
  Map<String, String> _userNames = {};
  List<GiftModel> _filteredGifts = [];
  String _filterOption = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  void _loadPledgedGifts() {
    final currentUserId = _authService.currentUser!.uid;
    _giftService.getPledgedGiftsByUser(currentUserId).listen((giftList) async {
      Map<String, EventModel> fetchedEventDetails = {};
      Map<String, String> fetchedUserNames = {};

      for (var gift in giftList) {
        // Fetch event details if not already fetched
        if (!_eventDetails.containsKey(gift.eventId)) {
          final event = await _eventService.getEventById(gift.eventId);
          if (event != null) {
            fetchedEventDetails[gift.eventId] = event;

            // Fetch user name if not already fetched
            if (!_userNames.containsKey(event.userId)) {
              final user = await _userService.getUser(event.userId);
              if (user != null) {
                fetchedUserNames[event.userId] = user.name;
              }
            }
          }
        }
      }

      setState(() {
        _eventDetails.addAll(fetchedEventDetails);
        _userNames.addAll(fetchedUserNames);
        _gifts = giftList
          ..sort((a, b) {
            final dateA = _eventDetails[a.eventId]?.date ?? DateTime.now();
            final dateB = _eventDetails[b.eventId]?.date ?? DateTime.now();
            final isUpcomingA = dateA.isAfter(DateTime.now());
            final isUpcomingB = dateB.isAfter(DateTime.now());
            if (isUpcomingA && !isUpcomingB) return -1;
            if (!isUpcomingA && isUpcomingB) return 1;
            return dateA.compareTo(dateB);
          });
        _applyFilter();
        _isLoading = false;
      });
    });
  }

  void _applyFilter() {
    setState(() {
      if (_filterOption == 'all') {
        _filteredGifts = _gifts;
      } else if (_filterOption == 'upcoming') {
        _filteredGifts = _gifts.where((gift) {
          final date = _eventDetails[gift.eventId]?.date;
          return date != null && date.isAfter(DateTime.now());
        }).toList();
      } else if (_filterOption == 'past') {
        _filteredGifts = _gifts.where((gift) {
          final date = _eventDetails[gift.eventId]?.date;
          return date != null && date.isBefore(DateTime.now());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('My Pledged Gifts'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterOption = value;
                _applyFilter();
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('All Gifts')),
              PopupMenuItem(value: 'upcoming', child: Text('Upcoming Gifts')),
              PopupMenuItem(value: 'past', child: Text('Past Gifts')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredGifts.isEmpty
          ? const Center(child: Text('No pledged gifts found'))
          : ListView.builder(
        itemCount: _filteredGifts.length,
        itemBuilder: (context, index) {
          final gift = _filteredGifts[index];
          final event = _eventDetails[gift.eventId];
          final isUpcoming =
              event != null && event.date.isAfter(DateTime.now());
          final userName = _userNames[event?.userId] ?? 'Loading...';

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.card_giftcard,
                color: isUpcoming ? Colors.green : Colors.red,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.event, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        event?.name ?? 'Event',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    event != null
                        ? 'Due Date: ${event.date.toLocal()}'.split(' ')[2]
                        : 'Date unavailable',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: isUpcoming
                  ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'modify') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GiftDetailsPage(gift: gift),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'modify', child: Text('Modify')),
                ],
              )
                  : null,
            ),
          );
        },
      ),
    );
  }

}
