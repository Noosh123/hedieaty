import 'package:flutter/material.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/screens/local/PrivateGiftListPage.dart';
import 'package:hedieaty/screens/local/create_private_event_page.dart';

import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/gift_service.dart';
import 'package:hedieaty/services/local/local_event_service.dart';
import 'package:hedieaty/services/event_service.dart';
import 'package:hedieaty/services/local/local_gift_service.dart';

class PrivateEventListPage extends StatefulWidget {
  @override
  _PrivateEventListPageState createState() => _PrivateEventListPageState();
}

class _PrivateEventListPageState extends State<PrivateEventListPage> {
  final LocalEventService _localEventService = LocalEventService();
  final AuthService _authService = AuthService();
  final EventService _eventService = EventService(); // For publishing events
  final LocalGiftService _localGiftService = LocalGiftService();
  final GiftService _giftService = GiftService();

  List<EventModel> _events = [];
  List<String> _selectedEventIds = [];
  String _sortOption = 'name'; // Default sorting option
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivateEvents();
  }

  void _loadPrivateEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _localEventService.getAllEvents();
      setState(() => _events = events);
      _sortEvents();
    } catch (e) {
      print('Error loading private events: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortEvents() {
    setState(() {
      if (_sortOption == 'name') {
        _events.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortOption == 'category') {
        _events.sort((a, b) => a.category.compareTo(b.category));
      } else if (_sortOption == 'date') {
        _events.sort((a, b) => a.date.compareTo(b.date));
      }
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _localEventService.deleteEvent(eventId);
      _loadPrivateEvents(); // Refresh the event list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  Future<void> _publishSelectedEvents() async {
    setState(() => _isLoading = true);
    try {
      for (var eventId in _selectedEventIds) {
        // Fetch the event from the local database
        final event = await _localEventService.getEventById(eventId);

        if (event != null) {
          // Assign the current user's ID to the event
          final userId = _authService.currentUser!.uid;
          final eventWithUserId = event.copyWith(userId: userId);

          // Publish the event to Firestore and get the new Firestore event ID
          final newEventId = await _eventService.addEventAndGetId(eventWithUserId);

          // Fetch all gifts associated with the event from the local database
          final gifts = await _localGiftService.getGiftsByEventId(eventId);

          for (var gift in gifts) {
            // Update the eventId in the gift to the new Firestore event ID
            final updatedGift = gift.copyWith(eventId: newEventId, userId: userId);

            // Publish the gift to Firestore
            await _giftService.addGift(updatedGift);

            // Remove the gift from the local database
            await _localGiftService.deleteGift(gift.id);
          }

          // Remove the event from the local database
          await _localEventService.deleteEvent(eventId);
        }
      }

      _selectedEventIds.clear();
      _loadPrivateEvents(); // Refresh the event list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected events and gifts published successfully!')),
      );
    } catch (e) {
      print('Error publishing events and gifts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish events and gifts: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('My Private Events'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortOption = value);
              _sortEvents();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Text('Sort by Category'),
              ),
              const PopupMenuItem(
                value: 'date',
                child: Text('Sort by Date'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text('No private events found'))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final isSelected = _selectedEventIds.contains(event.id);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedEventIds.add(event.id);
                    } else {
                      _selectedEventIds.remove(event.id);
                    }
                  });
                },
              ),
              title: Text(event.name),
              subtitle: Text(
                'Category: ${event.category}\n'
                    'Date: ${event.date.toLocal()}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePrivateEventPage(
                          event: event,
                        ),
                      ),
                    );
                    _loadPrivateEvents(); // Refresh after editing
                  } else if (value == 'delete') {
                    await _deleteEvent(event.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrivateGiftListPage(
                      eventId: event.id,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedEventIds.isNotEmpty)
            FloatingActionButton.extended(
              backgroundColor: Colors.blue,
              onPressed: _publishSelectedEvents,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Publish'),
            ),
          const SizedBox(height: 8),
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePrivateEventPage(),
                ),
              );
              _loadPrivateEvents(); // Refresh after adding a new event
            },
            child: const Icon(Icons.add_card_sharp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
