import 'package:flutter/material.dart';
import 'package:hedieaty/services/image_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hedieaty/models/gift_model.dart';
import 'package:hedieaty/services/local/local_gift_service.dart';
import 'dart:io';

class CreatePrivateGiftPage extends StatefulWidget {
  final GiftModel? gift; // Pass the gift model if editing
  final String eventId; // Event ID for the gift
  final bool isEdit; // Flag to differentiate between Add and Edit

  const CreatePrivateGiftPage({
    Key? key,
    required this.eventId,
    this.gift,
    this.isEdit = false,
  }) : super(key: key);

  @override
  State<CreatePrivateGiftPage> createState() => _CreatePrivateGiftPageState();
}

class _CreatePrivateGiftPageState extends State<CreatePrivateGiftPage> {
  final _formKey = GlobalKey<FormState>();
  final LocalGiftService _localGiftService = LocalGiftService();
  final ImageService _imageService = ImageService();

  String? _giftName;
  String? _description;
  String? _category;
  double? _price;
  String? _imageUrl;
  String _status = "available";

  final List<String> _categories = [
    'Electronics',
    'Books',
    'Clothing',
    'Toys',
    'Other',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Pre-fill form fields if editing
    if (widget.isEdit && widget.gift != null) {
      final gift = widget.gift!;
      _giftName = gift.name;
      _description = gift.description;
      _category = gift.category;
      _price = gift.price;
      _imageUrl = gift.image;
      _status = gift.status;
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Pick image from gallery or camera
      final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() => _isLoading = true);

        // Upload image using ImageService
        final imageUrl = await _imageService.uploadImage(pickedImage.path);

        if (imageUrl != null) {
          setState(() => _imageUrl = imageUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
        } else {
          throw Exception('Image upload failed');
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void _saveGift() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        // Prepare the gift model
        final GiftModel newGift = GiftModel(
          id: widget.isEdit ? widget.gift!.id : DateTime.now().toIso8601String(),
          eventId: widget.eventId,
          userId: 'local', // Set a placeholder user ID for local database
          name: _giftName!,
          description: _description ?? '',
          category: _category!,
          price: _price!,
          image: _imageUrl ?? '',
          status: _status,
          pledgedBy: null,
        );

        if (widget.isEdit) {
          // Update gift
          await _localGiftService.updateGift(newGift);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gift updated successfully!')),
          );
        } else {
          // Add new gift
          await _localGiftService.addGift(newGift);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gift added successfully!')),
          );
        }

        Navigator.pop(context); // Return to the previous screen
      } catch (e) {
        print('Error saving gift: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save gift: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Text(widget.isEdit ? 'Edit Private Gift' : 'Add Private Gift'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Gift Name
              TextFormField(
                initialValue: _giftName,
                decoration: const InputDecoration(
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
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _description = value,
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

              // Price
              TextFormField(
                initialValue: _price?.toString(),
                decoration: const InputDecoration(
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

              // Image Upload Section
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    image: (_imageUrl != null && _imageUrl!.isNotEmpty)
                        ? DecorationImage(
                      image: NetworkImage(_imageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (_imageUrl == null || _imageUrl!.isEmpty)
                      ? const Icon(
                    Icons.add_a_photo,
                    size: 50,
                    color: Colors.grey,
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[800],
                ),
                onPressed: _saveGift,
                child: Text(
                  widget.isEdit ? 'Update Gift' : 'Add Gift',
                  style: TextStyle(color: Colors.green[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
