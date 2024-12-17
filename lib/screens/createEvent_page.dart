import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/event_service.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  String? _eventName;
  String? _category;
  DateTime? _eventDate;
  String? _location;
  String? _description;

  final List<String> _categories = [
    'Birthday',
    'Wedding',
    'Anniversary',
    'Graduation',
    'Holiday',
    'Other'
  ];

  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        final String userId = _authService.currentUser!.uid;

        // Prepare the event model
        final EventModel newEvent = EventModel(
          id: '', // Firestore will generate this, so keep it empty for now
          userId: userId,
          name: _eventName!,
          category: _category!,
          date: _eventDate!,
          location: _location ?? '',
          description: _description ?? '',
        );

        // Save to Firestore
        await _eventService.addEvent(newEvent);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );

        Navigator.pop(context); // Return to the previous screen
      } catch (e) {
        print('Error saving event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: const Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Event Name
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Event name is required' : null,
                onSaved: (value) => _eventName = value,
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) => _category = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),

              // Event Date Picker
              GestureDetector(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _eventDate = selectedDate;
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Event Date',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    _eventDate == null ? 'Event date is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _location = value,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 32),

              // Save Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveEvent,
                child: const Text(
                  'Save Event',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
