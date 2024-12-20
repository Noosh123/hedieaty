import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hedieaty/models/event_model.dart';
import 'package:hedieaty/services/auth_service.dart';
import 'package:hedieaty/services/event_service.dart';

class CreateEventPage extends StatefulWidget {
  final EventModel? event; // Optional parameter for editing

  CreateEventPage({this.event}); // Constructor to accept event for editing

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
  final Color primaryColor = const Color(0xFFFF7B7B); // Soft coral
  final Color secondaryColor = const Color(0xFF98D7C2); // Mint green
  final Color accentColor = const Color(0xFFE2D1F9); // Light purple
  final Color goldAccent = const Color(0xFFFFD700); // Gold
  final Color backgroundColor = const Color(0xFFFFFAF0); // Cream

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing data
    if (widget.event != null) {
      _eventName = widget.event!.name;
      _category = widget.event!.category;
      _eventDate = widget.event!.date;
      _location = widget.event!.location;
      _description = widget.event!.description;
      _dateController.text = DateFormat('yyyy-MM-dd').format(widget.event!.date);
    }
  }

  void _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        final String userId = _authService.currentUser!.uid;

        if (widget.event == null) {
          // Add new event
          final EventModel newEvent = EventModel(
            id: '',
            userId: userId,
            name: _eventName!,
            category: _category!,
            date: _eventDate!,
            location: _location ?? '',
            description: _description ?? '',
          );
          await _eventService.addEvent(newEvent);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
        } else {
          // Update existing event
          final Map<String, dynamic> updatedData = {
            'name': _eventName,
            'category': _category,
            'date': _eventDate,
            'location': _location,
            'description': _description,
          };
          await _eventService.updateEvent(widget.event!.id!, updatedData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully!')),
          );
        }

        Navigator.pop(context); // Return to the previous screen
      } catch (e) {
        print('Error saving event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save event: $e')),
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
      backgroundColor: backgroundColor,
      appBar: AppBar(

        backgroundColor: primaryColor,
        title: Text(widget.event == null ? 'Create Event' : 'Edit Event',style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Event Name
              TextFormField(
                initialValue: _eventName,
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
                value: _category,
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
                    initialDate: _eventDate ?? DateTime.now(),
                    firstDate: DateTime.now(), // Prevent past dates
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
                initialValue: _location,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _location = value,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                initialValue: _description,
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
