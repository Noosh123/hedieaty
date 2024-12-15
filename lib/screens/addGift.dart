import 'package:flutter/material.dart';

class createGift extends StatefulWidget {
  final bool isEdit; // Flag to differentiate between Add and Edit
  const createGift({Key? key, this.isEdit = false}) : super(key: key);

  @override
  State<createGift> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<createGift> {
  final _formKey = GlobalKey<FormState>();
  String? _giftName;
  String? _description;
  String? _category;
  double? _price;
  bool _isPledged = false;

  final List<String> _categories = [
    'Electronics',
    'Books',
    'Clothing',
    'Toys',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text(widget.isEdit ? 'Edit Gift' : 'Add Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Gift Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Gift Name',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _giftName = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 16),
              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((category) =>
                    DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => _category = value,
                validator: (value) =>
                value == null || value.isEmpty ? 'Category is required' : null,
              ),
              const SizedBox(height: 16),
              // Price
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.tryParse(value ?? ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  return price == null || price <= 0
                      ? 'Enter a valid price'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              // Image Upload Placeholder
              GestureDetector(
                onTap: () {
                  // Implement image picker functionality
                  print('Upload image');
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              // Status Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pledged Status:'),
                  Switch(
                    value: _isPledged,
                    onChanged: (value) {
                      setState(() {
                        _isPledged = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[800]
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Save the gift details
                    print('Gift Name: $_giftName');
                    print('Description: $_description');
                    print('Category: $_category');
                    print('Price: $_price');
                    print('Status: ${_isPledged ? 'Pledged' : 'Available'}');
                    Navigator.pop(context);
                  }
                },
                child: Text('Save Gift',style: TextStyle(color: Colors.green[800]),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
